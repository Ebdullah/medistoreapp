class StockTransfersController < ApplicationController
  before_action :set_branch
  before_action :set_stock_transfer, only: [:show, :edit, :update, :destroy]

  def index
    @stock_transfers = @branch.stock_transfers
  end

  def new
    @branch = Branch.find(params[:branch_id])
    @stock_transfer = StockTransfer.new
  end

  def create
    logger.debug "Incoming params: #{params.inspect}"
  
    @branch = Branch.find(params[:branch_id])
    @stock_transfer = @branch.stock_transfers.new(stock_transfer_params)
  
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
      redirect_to [@branch, @stock_transfer], notice: 'Stock transfer was successfully created.'
    else
      render :new
    end
  end
  

  def show
    @stock_transfer
  end

  def edit
    @stock_transfer
  end

  def update
    if @stock_transfer.update(stock_transfer_params)
      redirect_to branch_stock_transfer_path(@branch, @stock_transfer), notice: 'Stock transfer updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stock_transfer.destroy
    redirect_to branch_stock_transfers_path(@branch), notice: 'Stock transfer deleted successfully.'
  end

  def approve
    @branch = Branch.find(params[:branch_id])
    @stock_transfer = @branch.stock_transfers.find_by(id: params[:id])

    ActiveRecord::Base.transaction do
      @stock_transfer.update!(status: :approved)
  
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

    @stock_transfer.update(status: :denied)
    redirect_to branch_stock_transfer_path(@branch, @stock_transfer), notice: 'Stock transfer was successfully denied.'
  end

  private

  def set_branch
    @branch = Branch.find(params[:branch_id])
  end

  def set_stock_transfer
    @stock_transfer = @branch.stock_transfers.find(params[:id])
  end

  def stock_transfer_params
    params.require(:stock_transfer).permit(:receiving_branch_id, :status)
  end
end