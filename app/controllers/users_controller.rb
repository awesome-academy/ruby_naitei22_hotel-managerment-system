class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    @users = User.recent
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      log_in(@user)
      flash[:success] = t("users.create.success")
      redirect_to @user, status: :see_other
    else
      flash[:error] = t("users.create.failure")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t("users.not_found")
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(User::USER_PERMIT)
  end
end
