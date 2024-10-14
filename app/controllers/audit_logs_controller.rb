class AuditLogsController < ApplicationController
    # before_action :authenticate_user!, :authorize_super_admin
    before_action :set_branch
    before_action :set_audit_log, only: [:show, :destroy]
    after_action :verify_authorized

    
    def index
        per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5
        @audit_logs = policy_scope(AuditLog).page(params[:page]).per(per_page)
        authorize @audit_logs
    end

    def show
        authorize @audit_log
    end
    
    def destroy
        authorize @audit_log
        if @audit_log.destroy
            redirect_to branch_audit_logs_path(@branch), notice: 'Audit log was successfully deleted.'
        else
            redirect_to branch_audit_logs_path(@branch), alert: 'Failed to delete audit log.'
        end
    end
      

    private

    def set_branch
        @branch = Branch.find(params[:branch_id])
    end

    def set_audit_log
        @audit_log = @branch.audit_logs.find(params[:id])
    end
    
    # def authorize_super_admin
    #     redirect_to root_path, alert: "Not authorized" unless current_user.super_admin?
    # end
    
end
