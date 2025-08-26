class UsersController < ApplicationController
  before_action :set_user, only: %i(edit show update)

  # GET /users
  def index
    @users = User.recent
  end

  # GET /users/:id
  def show
    @reviews = @user.reviews.includes(request: :booking)
  end

  # GET /users/:id/edit
  def edit; end

  # PUT /users/:id
  def update
    if @user.update(user_params)
      flash[:success] = t(".success")
      render :edit, status: :see_other
    else
      flash[:danger] = t(".failure")
      render :edit, status: :unprocessable_entity
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
