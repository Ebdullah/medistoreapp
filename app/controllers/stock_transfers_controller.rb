class StockTransfersController < ApplicationController
  before_action :set_branch
  before_action :set_stock_transfer, only: [:show, :edit, :update, :destroy, :approve, :deny]
  after_action :verify_authorized, except: [:index]

  def index
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5
    @stock_transfers = @branch.stock_transfers.page(params[:page]).per(per_page)
    if current_user.super_admin?
      @stock_transfers = @branch.stock_transfers.joins(:pdf_attachment).page(params[:page]).per(per_page)
    end
    authorize StockTransfer
  end

  def new
    @stock_transfer = @branch.stock_transfers.new
    authorize @stock_transfer
  end

  def create
    logger.debug "Incoming params: #{params.inspect}"
  
    @branch = Branch.find(params[:branch_id])
    @stock_transfer = @branch.stock_transfers.new(stock_transfer_params)
    authorize @stock_transfer
  
    medicines_hash = {}
  
    if params[:stock_transfer][:medicines_attributes].present?
      if params[:stock_transfer][:medicines_attributes].is_a?(Array)
        params[:stock_transfer][:medicines_attributes].each do |medicine|
          medicine_id = medicine[:medicine_id]
          quantity = medicine[:quantity].to_i
          next if medicine_id.blank? || quantity <= 0
  
          medicine_name = Medicine.find(medicine_id).name
          medicines_hash[medicine_name] = quantity
        end
      end
    end
  
    @stock_transfer.medicines = medicines_hash.to_json
  
    if @stock_transfer.save
      notify_branch_admins(@stock_transfer)
      redirect_to [@branch, @stock_transfer], notice: 'Stock transfer was successfully created.'
    else
      render :new
    end
  end
  

  def show
    authorize @stock_transfer
  end

  def edit
    authorize @stock_transfer
  end

  def update
    authorize @stock_transfer
    if @stock_transfer.update(stock_transfer_params)
      redirect_to branch_stock_transfer_path(@branch, @stock_transfer), notice: 'Stock transfer updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @stock_transfer
    @stock_transfer.destroy
    redirect_to branch_stock_transfers_path(@branch), notice: 'Stock transfer deleted successfully.'
  end

  def approve
    @branch = Branch.find(params[:branch_id])
    @stock_transfer = @branch.stock_transfers.find_by(id: params[:id])
    authorize @stock_transfer

    ActiveRecord::Base.transaction do
      @stock_transfer.update!(status: :approved)  
      notify_branch_admins_req_approved(@stock_transfer)

      medicines = JSON.parse(@stock_transfer.medicines)
  
      medicines.each do |medicine_name, quantity|
        medicine = Medicine.find_by(name: medicine_name)
  
        receiving_branch_medicine = Medicine.find_by(branch_id: @stock_transfer.receiving_branch_id, name: medicine_name)
  
        if receiving_branch_medicine.nil? || receiving_branch_medicine.stock_quantity < quantity
          raise ActiveRecord::Rollback, "Insufficient stock for #{medicine_name} in the receiving branch."
        end
  
        receiving_branch_medicine.update!(stock_quantity: receiving_branch_medicine.stock_quantity - quantity)
  
        requesting_branch_medicine = Medicine.find_or_initialize_by(branch_id: @stock_transfer.requesting_branch_id, name: medicine_name)
  
        if requesting_branch_medicine.persisted?
          requesting_branch_medicine.stock_quantity += quantity
        else
          requesting_branch_medicine.stock_quantity = quantity
        end
  
        requesting_branch_medicine.price = medicine.price
        requesting_branch_medicine.description = medicine.description
        requesting_branch_medicine.expiry_date = medicine.expiry_date
        requesting_branch_medicine.save!
      end
  
      redirect_to branch_stock_transfer_path(@branch, @stock_transfer), notice: 'Stock transfer was successfully approved.'
    rescue ActiveRecord::RecordInvalid => e
      redirect_to branch_stock_transfer_path(@branch, @stock_transfer), alert: "Approval failed: #{e.message}"
    end
  end  
  
  def deny
    @branch = Branch.find(params[:branch_id])
    @stock_transfer = @branch.stock_transfers.find_by(id: params[:id])
    authorize @stock_transfer

    @stock_transfer.update(status: :denied)
    notify_branch_admins_req_denied(@stock_transfer)
    redirect_to branch_stock_transfer_path(@branch, @stock_transfer), notice: 'Stock transfer was successfully denied.'
  end

  def pdf
    @stock_transfer = @branch.stock_transfers.find(params[:id])
    authorize @stock_transfer
    
    pdf = Prawn::Document.new
    pdf.text "Stock Transfer Invoice ##{@stock_transfer.id}", size: 40, style: :bold, align: :center
    pdf.move_down 20
  
    pdf.text "Requesting Branch: #{@stock_transfer.requesting_branch.name}"
    pdf.text "Receiving Branch: #{@stock_transfer.receiving_branch.name}"
    pdf.text "Status: #{@stock_transfer.status.humanize}"
    pdf.move_down 20
  
    header = ["Medicine Name", "Quantity"]

    medicines_data = @stock_transfer.medicines.is_a?(String) ? JSON.parse(@stock_transfer.medicines) : @stock_transfer.medicines

    data = medicines_data.map do |medicine_name, quantity|
      [medicine_name, quantity]
    end
  
    table_data = [header] + data
  
    table_width = pdf.bounds.width * 0.8
  
    pdf.bounding_box([pdf.bounds.left + (pdf.bounds.width - table_width) / 2, pdf.cursor], width: table_width) do
      pdf.table(table_data, header: true, width: table_width) do
        row(0).font_style = :bold
        row(0).background_color = '000000'
        row(0).text_color = 'cccccc'
        cells.style do |cell|
          cell.border_width = 1
          cell.border_color = '000000'
        end
      end
    end
    
    send_data pdf.render, filename: "stock_transfer_#{@stock_transfer.id}.pdf", type: 'application/pdf'
  end

  def upload_pdf
    @stock_transfer = StockTransfer.find(params[:id])
    authorize @stock_transfer

    if @stock_transfer.update(pdf: params[:stock_transfer][:pdf])
        
      redirect_to branch_stock_transfer_path(@branch, @stock_transfer), notice: 'PDF uploaded successfully.'
    else
      render :show, alert: 'Failed to upload PDF.'
    end
  end

  private

  def set_branch
    @branch = Branch.find(params[:branch_id])
  end

  def set_stock_transfer
    @stock_transfer = @branch.stock_transfers.find(params[:id])
  end

  def stock_transfer_params
    params.require(:stock_transfer).permit(:receiving_branch_id, :status, :pdf)
  end

  def notify_branch_admins(stock_transfer)
    requesting_admin = stock_transfer.requesting_branch.users.find_by(role: :branch_admin)
    receiving_admin = stock_transfer.receiving_branch.users.find_by(role: :branch_admin)
  
    message = "A new stock transfer ##{stock_transfer.id} has been created between #{stock_transfer.requesting_branch.name} and #{stock_transfer.receiving_branch.name}."
  
    notification = Notification.create!(customer: requesting_admin, branch: stock_transfer.requesting_branch, message: message, status: 'unread') if requesting_admin
    notification = Notification.create!(customer: receiving_admin, branch: stock_transfer.receiving_branch, message: message, status: 'unread') if receiving_admin

    SendStockRequestNotificationJob.perform_later(notification.id)
  end

  def notify_branch_admins_req_approved(stock_transfer)
    requesting_admin = stock_transfer.requesting_branch.users.find_by(role: :branch_admin)
    receiving_admin = stock_transfer.receiving_branch.users.find_by(role: :branch_admin)
  
    message = "Stock transfer Request ##{stock_transfer.id} has been approved for #{stock_transfer.requesting_branch.name}."
  
    notification = Notification.create!(customer: requesting_admin, branch: stock_transfer.requesting_branch, message: message, status: 'unread') if requesting_admin
    notification = Notification.create!(customer: receiving_admin, branch: stock_transfer.receiving_branch, message: message, status: 'unread') if receiving_admin

    SendStockRequestNotificationJob.perform_later(notification.id)
  end

  def notify_branch_admins_req_denied(stock_transfer)
    requesting_admin = stock_transfer.requesting_branch.users.find_by(role: :branch_admin)
    receiving_admin = stock_transfer.receiving_branch.users.find_by(role: :branch_admin)
    
    super_admin = User.find_by(role: 0)
    message = "Stock transfer Request ##{stock_transfer.id} has been denied for #{stock_transfer.requesting_branch.name} by #{super_admin.name}."
  
    notification = Notification.create!(customer: requesting_admin, branch: stock_transfer.requesting_branch, message: message, status: 'unread') if requesting_admin
    notification = Notification.create!(customer: receiving_admin, branch: stock_transfer.receiving_branch, message: message, status: 'unread') if receiving_admin

    SendStockRequestNotificationJob.perform_later(notification.id)
  end
end