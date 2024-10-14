# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]


  protected

  def after_sign_in_path_for(resource)
    if resource.super_admin? || resource.branch_admin?
      dashboard_path
    elsif resource.cashier?
      branch_records_path(resource.branch_id)
    elsif resource.customer?
      portal_users_path
    else
      super # Fallback to Devise's default behavior
    end
  end
  
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
