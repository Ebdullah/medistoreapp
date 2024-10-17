class RefundsController < ApplicationController
    before_action :set_refund, only: [:update, :approve, :deny]
  
    def index
      per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5
      @branch = Branch.find(params[:branch_id])
      @refunds = Refund.joins(:record).where(records: { branch_id: @branch.id }).order(created_at: :desc).page(params[:page]).per(per_page)
    end
  
    def new
      @record = Record.find(params[:record_id])
      @branch = Branch.find(@record.branch_id)
      @refund = @record.refunds.new
    end
  
    def create
      @branch = Branch.find(params[:branch_id])
      @record = @branch.records.find(params[:refund][:record_id])
      @refund = @record.refunds.new(refund_params)
        
      puts @refund.customer_id = @record.customer.id
      @refund.branch_id = @branch.id

      if @refund.save
        branch_admin = User.find_by(branch_id: @branch.id, role: :branch_admin)
        CreateBranchRefundNotificationJob.perform_later(@branch, @refund)
        flash[:success] = 'Refund has been created and is pending approval.'
        redirect_to my_purchases_path
      else
        flash.now[:alert] = @refund.errors.full_messages.to_sentence
        flash[:error] = 'Refund could not be created.'
        render :new
      end
    end
  
    def update
      if @refund.update(refund_params)
        flash[:success] = 'Refund status updated successfully.'
        redirect_to @refund.record
      else
        flash[:error] = 'Failed to update refund.'
        render :edit
      end
    end

    def approve
        @branch = Branch.find(params[:branch_id])
        @record = @refund.record
      
        if @refund.update(status: 'refunded')
          RefundNotificationJob.perform_later(@refund)
          @record.record_items.each do |record_item|
            medicine = Medicine.find(record_item.medicine_id)
            medicine.increment!(:stock_quantity, record_item.quantity)
          end
      
          # Stripe refund
          if @record.payment_method == 'card' && @record.payment_intent_id.present?
            begin
              Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
      
              refund = Stripe::Refund.create({
                payment_intent: @record.payment_intent_id,
              })
      
              if refund.status == 'succeeded'
                @record.soft_delete 
                flash[:success] = 'Refund has been approved and processed successfully.'
                redirect_to branch_refunds_path(@branch), notice: 'Successfully refunded'
              else
                flash[:error] = 'Refund was not successful. Please check the details.'
                render :index, status: :unprocessable_entity
              end
            rescue Stripe::StripeError => e
              flash[:error] = "Stripe error: #{e.message}. Refund was not processed."
              render :index
            end
          else
            @record.soft_delete
            flash[:success] = 'Refund has been approved.'
            redirect_to branch_refunds_path(@branch)
          end
        else
          flash[:error] = 'Failed to approve refund.'
          render :index
        end
    end
  
    def deny
      @branch = Branch.find(params[:branch_id])
      if @refund.update(status: 'rejected')
        DenyRefundNotificationJob.perform_later(@refund)
        flash[:success] = 'Refund has been denied.'
        redirect_to branch_refunds_path(@branch)
      else
        flash[:error] = 'Failed to deny refund.'
        render :index
      end
    end
  
    private
  
    def set_record
      @record = Record.find(params[:record_id])
    end
  
    def set_refund
      @refund = Refund.find(params[:id])
    end
  
    def refund_params
      params.require(:refund).permit(:amount, :status, :record_id, :customer_id)
    end
  
    def notify_branch_admin(branch, refund, branch_admin)
      return unless branch_admin
  
      Notification.create(
        customer_id: branch_admin.id,
        branch: branch,
        message: "A new refund (ID: #{refund.id}) has been created and is pending approval.",
        status: 'unread' # Corrected closing quote
      )
    end
  end
  