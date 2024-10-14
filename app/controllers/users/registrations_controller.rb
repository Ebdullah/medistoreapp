# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  skip_before_action :require_no_authentication, only: [:new, :create]

  def create
    build_resource(sign_up_params)

    if resource.email.blank?
      flash[:alert] = "Email can't be blank"
      render :new, status: :unprocessable_entity and return
    end

    begin
      if resource.save!
        WelcomeEmailJob.perform_later(resource)
        set_flash_message! :notice, :signed_up
        redirect_to users_path, notice: 'User was successfully created.'
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.message # This will capture the validation error message
      clean_up_passwords resource
      set_minimum_password_length
      render :new, status: :unprocessable_entity
    end
  end


  protected

  def after_sign_up_path_for(resource)
    portal_users_path 
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def sign_up_params
    permitted_params = params.require(:user).permit(:email, :password, :password_confirmation, :name, :branch_id, :phone, :role)

    permitted_params
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :name, :phone)
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
