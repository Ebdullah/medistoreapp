class RecordsController < ApplicationController
  before_action :set_branch, only: [:new, :index, :create, :edit, :purchase, :create_purchase, :show, :undo, :pdf]
  before_action :set_record, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized

  def index
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5
    @records = @branch.records.all
    @records = policy_scope(Record.active).where(branch_id: @branch.id).page(params[:page]).per(per_page)
    authorize Record
  end

  def show
    authorize @record
  end

  def new
    @record = @branch.records.build
    @record.record_items.build
    authorize @record
  end

  def create
    ActiveRecord::Base.transaction do
      customer = User.find_or_create_by!(name: record_params[:customer_name], phone: record_params[:customer_phone]) do |user|
        user.email = generate_random_email
        user.password = Devise.friendly_token[0, 20]
        user.role = :customer
        user.phone = record_params[:customer_phone]
      end
  
      @record = @branch.records.build(record_params.except(:customer_name, :customer_phone))
      @record.customer_id = customer.id
      @record.customer_name = record_params[:customer_name]
      @record.customer_phone = record_params[:customer_phone]
  
      @record.total_amount = calculate_total_amount(@record.record_items)
      
      authorize @record

      if @record.save
        WelcomeEmailJob.perform_later(customer) if customer.created_at == customer.updated_at
        create_audit_logs
        redirect_to branch_record_path(@branch, @record), notice: 'Bill was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error: #{e.message}"
    render :new
  end
    

  def edit
    authorize @record
  end

  def update
    authorize @record
    if @record.update(record_params)
        redirect_to branch_record_path(@branch, @record), notice: "Bill Succesfully Updated."
    else
        render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @record
    @record.archive_record(current_user)
    @record.soft_delete
    redirect_to branch_records_path(@branch), notice: "Record was successfully archived. "
  end

  def undo
    @archive = Archive.find_by(record_id: params[:id])

    @record = Record.find_by(id: @archive.record_id)
    authorize @record

    if @archive
      if @record
        @record.restore
        @archive.destroy
    
        redirect_to branch_archives_path(@branch), notice: 'Record was successfully restored.'
      else
        redirect_to branch_archives_path(@branch), alert: 'original record not found.'
      end
    else
      redirect_to branch_archives_path(@branch), alert: 'Archive record not found.'
    end
  end


  def pdf
    @record = @branch.records.find(params[:id])
    authorize @record
  
    pdf = Prawn::Document.new
    pdf.text "Invoice ##{@record.id}", size: 40, style: :bold, align: :center
    pdf.move_down 20
  
    pdf.text "Customer Name: #{@record.customer_name}"
    pdf.text "Customer Phone: #{@record.customer_phone}"
    pdf.text "Total Amount: #{@record.total_amount}"
    pdf.text "Payment Method: #{@record.payment_method}"
    pdf.move_down 20
  
    header = ["Medicine Name", "Quantity", "Price"]
    data = @record.record_items.map do |item|
      [item.medicine.name, item.quantity, item.price]
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
  
    pdf.move_down 20
    pdf.text "Total Amount: #{@record.total_amount}", size: 24, style: :bold, align: :right
  
    pdf.move_down 40
    pdf.text "Thank you for your business!", size: 16, style: :italic, align: :center
    pdf.text "Contact us: medistore@example.com | Phone: (123) 456-7890", size: 12, align: :center
  
    send_data pdf.render, filename: "invoice_#{@record.id}.pdf", type: 'application/pdf', disposition: 'attachment'
  end

  def select_branch_for_purchase
    authorize Record, :select_branch_for_purchase?
    @branches = Branch.all
  end
  

  def my_purchases
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5

    @purchases = Record.where(customer_id: current_user.id).includes(record_items: :medicine).page(params[:page]).per(per_page)
    
    if params[:search].present?
      @purchases = @purchases.joins(record_items: :medicine)
                             .where('medicines.name ILIKE ?', "%#{params[:search]}%")
                             .distinct.order(created_at: :desc)
    end
    authorize Record
  end

  def purchase
    @branch = Branch.find(params[:branch_id] || session[:selected_branch_id])
    @record = @branch.records.build
    @record.record_items.build
    session[:selected_branch_id] = @branch.id
    @medicines = @branch.medicines.where(expired: false)

    authorize Record
  end

  def create_purchase
    @branch = Branch.find(params[:branch_id] || session[:selected_branch_id])
    session[:selected_branch_id] = @branch.id
    @medicines = @branch.medicines.where(expired: false)
    
    @record = @branch.records.new(purchase_params)
    
    authorize @record
    
    @record.branch = @branch
    @record.cashier_id = current_user.id
    @record.customer_id = current_user.id
    @record.customer_name = params[:customer_name] if params[:customer_name].present?
    @record.customer_phone = params[:customer_phone] if params[:customer_phone].present?
    
    @record.total_amount = calculate_total_amount(@record.record_items)
  
    ActiveRecord::Base.transaction do
      if @record.save
        if @record.payment_method == 'cash'
          flash[:notice] = 'Purchase completed successfully with cash.'
          redirect_to show_purchase_branch_record_path(@branch, @record)
        else
          Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
          
          stripe_token = params[:record][:stripe_token]
          stripe_email = params[:record][:stripe_email]

          amount_in_cents = (@record.total_amount * 100).to_i

          payment_method = Stripe::PaymentMethod.create({
            type: 'card',
            card: { token: stripe_token },
          })
          
          intent = Stripe::PaymentIntent.create({
            amount: amount_in_cents,
            currency: 'usd',
            payment_method: payment_method.id,
            receipt_email: stripe_email,
            confirm: true,
            automatic_payment_methods: {
              enabled: true,
              allow_redirects: "never"
            },
            description: 'Medicine purchase',
          })
          
          @record.payment_intent_id = intent.id
  
          if intent.status == 'succeeded'
            @record.update(payment_method: 'card')
            flash[:notice] = 'Purchase completed successfully with card.'
            redirect_to show_purchase_branch_record_path(@branch, @record)
          else
            flash.now[:alert] = 'Payment failed. Please try again.'
            render :purchase, status: :unprocessable_entity
          end
        end
      else
        flash.now[:alert] = 'Error saving the record. Please check the details and try again.'
        @branches = Branch.all
        render :purchase, status: :unprocessable_entity
      end
    end
  
  rescue Stripe::CardError => e
    flash.now[:alert] = e.message
    render :purchase, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error: #{e.message}"
    render :purchase, status: :unprocessable_entity
  rescue Stripe::StripeError => e
    flash.now[:alert] = "Stripe error: #{e.message}"
    render :purchase, status: :unprocessable_entity
  end
  

  def show_purchase
    @branch = Branch.find(params[:branch_id] || session[:selected_branch_id])
    @record = Record.find(params[:id])

    authorize @record
      # Fetch the associated record items to include in the response
    @record_items = @record.record_items.includes(:medicine).select(:medicine_id, :quantity, :price)

    # Respond with JSON if it's an AJAX request
    respond_to do |format|
      format.html # For standard HTML requests (if you need a full view)
      format.json do
        render json: {
          customer_name: @record.customer.name,
          customer_phone: @record.customer.phone,
          record_items: @record_items.map do |item|
            {
              medicine_name: item.medicine.name,
              quantity: item.quantity,
              price: item.price
            }
          end
        }
      end
    end
  end
  
  private

  def set_branch
    @branch = Branch.find_by(id: params[:branch_id])
    unless @branch
      redirect_to branch_records_path(@branch,@record), alert: "Branch not found." # Redirect to an appropriate path
    end
  end

  def set_record
    @branch = Branch.find_by(id: params[:branch_id])

    if params[:id].present?
      @record = @branch.records.find_by(id: params[:id])
      if @record.nil?
        redirect_to branch_records_path(@branch), alert: "Record not found."
      end
    else
      @record = @branch.records.build if action_name.in?(%w[new create purchase create_purchase])
    end
  end

  def record_params
    params.require(:record).permit(
    :cashier_id,:customer_id, :customer_name,
    :customer_phone, :total_amount,:payment_method,
    record_items_attributes: [:id, :medicine_id, :quantity, :price, :_destroy]
    )
  end

  def purchase_params
    params.require(:record).permit(
      :customer_name,
      :customer_phone,
      :payment_method,
      :house_no,
      :postal_code,
      :address,
      :total_amount, 
      record_items_attributes: [:medicine_id, :quantity, :price] 
    )
  end

  def generate_random_email
    "customer_#{SecureRandom.hex(10)}@example.com"
  end

  def calculate_total_amount(record_items)
      record_items.sum { |item| item.quantity.to_f * item.price.to_f }
  end

  def create_audit_logs
      @record.record_items.each do |item|
          AuditLog.create!(
          branch: @branch,
          cashier: @record.cashier,
          record: @record,
          medicine: item.medicine,
          quantity_sold: item.quantity,
          total_amount: item.price * item.quantity,
          audited_from: @record.created_at
          )
      end
  end
end
