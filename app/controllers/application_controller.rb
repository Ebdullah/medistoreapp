class ApplicationController < ActionController::Base
  before_action :set_active_storage_url_options
  before_action :authenticate_user!
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected 

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = { host: request.base_url }
  end

  def after_sign_in_path_for(resource)
    if resource.super_admin? || resource.branch_admin?
      dashboard_path
    elsif resource.cashier?
        branch_records_path(resource.branch_id)
    elsif resource.customer?
      portal_users_path
    else
      root_path
    end
  end

  def user_not_authorized
      flash[:alert] = "You are not Authorized to perform this action."
      redirect_to (request.referrer || root_path)
  end
end
