class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @branches = Branch.all
    @users = User.all
    @medicines = Medicine.all
    @records = Record.all
    @audit_logs = AuditLog.all
    @stock_transfers = StockTransfer.all
  end
  
end
