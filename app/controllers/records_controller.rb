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
          # Create or find the customer
          customer = User.find_or_create_by!(name: record_params[:customer_name], phone: record_params[:customer_phones]) do |user|
            user.email = generate_random_email # To ensure email uniqueness
            user.password = Devise.friendly_token[0, 20] # Random password
            user.role = :customer
            user.phone = record_params[:customer_phone]
          end
          # Build the record with the new customer_id
          @record = @branch.records.build(record_params.except(:customer_name, :customer_phone))
          @record.total_amount = calculate_total_amount(@record.record_items)
          @record.customer_id = customer.id
    
          if @record.save
            redirect_to branch_record_path(@branch, @record), notice: 'Bill was successfully created.'
          else
            render :new
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
end
