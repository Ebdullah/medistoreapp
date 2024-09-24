class RecordsController < ApplicationController
    before_action :set_branch
    before_action :set_record, only: [:show, :edit, :update, :destroy]

    def index
        @records = @branch.records
    end

    def show
        @record
    end

    def new
        @record = @branch.records.build
        @record.record_items.build
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
      
          if @record.save
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
        @record
    end

    def update
        if @record.update(record_params)
            redirect_to branch_record_path(@branch, @record), notice: "Bill Succesfully Updated."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @record.destroy
        redirect_to branch_records_path(@branch), notice: "Bill was succesfully deleted."
    end

    def pdf
        @record = @branch.records.find(params[:id])
      
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
      
        # Define a smaller width for the table (e.g., 80% of the PDF width)
        table_width = pdf.bounds.width * 0.8
      
        # Center the table using bounding_box with specified width
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
      
      

    private

    def set_branch
        @branch = Branch.find(params[:branch_id])
    end

    def set_record
        @record = @branch.records.find(params[:id])
    end

    def record_params
        params.require(:record).permit(:cashier_id,:customer_id, :customer_name, :customer_phone, :total_amount,:payment_method,record_items_attributes: [:id, :medicine_id, :quantity, :price, :_destroy])
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
