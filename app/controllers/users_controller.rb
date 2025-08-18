class UsersController < ApplicationController
  before_action :set_user, only: %i(edit show)

  # GET /users
  def index
    @users = User.recent
  end

  # GET /users/:id
  def show; end

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new user_params

    if @user.save
      log_out
      @user.send_activation_email
      flash[:info] = t(".activate")
      redirect_to root_url, status: :see_other
    else
      flash[:danger] = t(".failure")
      render :new, status: :unprocessable_entity
    end
  end

  # PUT /users/:id
  def edit; end

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
