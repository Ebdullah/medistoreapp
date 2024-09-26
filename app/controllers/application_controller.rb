class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected 

  def after_sign_in_path_for(resource)
    if resource.super_admin?
      branches_path
    elsif resource.branch_admin?
      branches_path(resource.branch_id)
    elsif resource.cashier?
        branch_records_path(resource.branch_id)
    else
      root_path
    end
  end

  def user_not_authorized
      flash[:alert] = "You are not Authorized to perform this action."
      redirect_to (request.referrer || root_path)
  end
end
