class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    if current_user.branch_admin?
      @total_users = User.where(branch_id: current_user.branch_id).count
      @total_medicines = Medicine.where(branch_id: current_user.branch_id).count
      @total_branches = 1
      @branches = Branch.where(id: current_user.branch_id) 
    else
      @total_users = User.count
      @total_medicines = Medicine.count
      @total_branches = Branch.count
      @branches = Branch.all
    end
  end
end
