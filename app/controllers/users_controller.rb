class UsersController < ApplicationController
  before_action :set_branches

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      WelcomeEmailJob.perform_later(@user)
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


  private

  def user_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :role, :branch_id)
  end

  def set_branches
    @branches = Branch.all
  end
end
