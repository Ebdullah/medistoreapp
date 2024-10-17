class DisputesController < ApplicationController
    before_action :set_branch

    def index
        per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5
        @disputes = @branch.disputes.order(created_at: :desc).page(params[:page]).per(per_page)
    end

    def new
        @dispute = @branch.disputes.build(record_id: params[:record_id])
    end

    def create
        @dispute = @branch.disputes.build(dispute_params)
        @record = Record.find_by(id: dispute_params[:record_id])

        @dispute.record = @record

        if @dispute.save
            redirect_to branch_dispute_path(@branch,@dispute), notice: 'Dispute created succesfully.'
        else
            flash[:alert] = @dispute.errors.full_messages.join(", ")
            render :new, status: :unprocessable_entity
        end
    end

    def show
        @dispute = @branch.disputes.find(params[:id])
    end

    def failed
        @dispute = @branch.disputes.find(params[:id])
        if @dispute.update(status: 1)
            redirect_to branch_disputes_path(@branch, @dispute), notice: 'Dispute set to cancelled.'
        else
            flash[:alert] = 'Unable to cancel the dispute.'
            render :index
        end
    end


    def won
        @dispute = @branch.disputes.find(params[:id])
        if @dispute.update(status: 2)
            redirect_to branch_disputes_path(@branch, @dispute), notice: 'Dispute won'
        else
            flash[:alert] = 'Unable to approve the dispute.'
            render :index
        end
    end

    private
    def set_branch
        @branch = Branch.find(params[:branch_id])
    end

    def dispute_params
        params.require(:dispute).permit(:reason, :pdf, :status, :record_id)
    end
end
