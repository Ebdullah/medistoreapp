class UsersController < ApplicationController
  before_action :set_branches
  # after_action :verify_authorized


  def index
    @branches = Branch.all
    per_page = (params[:per_page] || 5).to_i
  
    if params[:branch_id].present? && params[:branch_id] != 'all'
      @users = User.where(branch_id: params[:branch_id]).page(params[:page]).per(per_page)
    else
      @users = User.page(params[:page]).per(per_page)
    end
  end
  
  def new
    @user = User.new
    @branches = Branch.all
  end

  def create
    @user = User.new(user_params)
    if @user.save
      WelcomeEmailJob.perform_later(@user)
      Rails.logger.debug("User created: #{@user.inspect}")
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
        redirect_to @user, notice: 'User was updated successfull.'
    else
        render :edit, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_path, status: :see_other
  end

  #for user portal
  def portal
  end

  def profile
    @user = User.find(params[:user_id])
  end


  private

  def user_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :role, :branch_id)
  end

  def set_branches
    @branches = Branch.all
  end
  

  def set_branch
    @branch = Branch.find(params[:branch_id]) if params[:branch_id].present?
  end
end
