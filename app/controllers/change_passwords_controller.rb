class ChangePasswordsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource :user

  before_action :set_user
  before_action :check_authen, only: :update

  # GET /users/:user_id/change_password/edit
  def edit; end

  # PATCH /users/:user_id/change_password
  def update
    if @user.update(change_password_params)
      bypass_sign_in(@user)
      flash[:success] = t(".success")
      redirect_to edit_user_change_password_path(@user)
    else
      flash.now[:danger] = t(".wrong_password")
      render :edit
    end
  end

  private

  def check_authen
    current_password = params.dig(:user, :current_password)
    return if @user.valid_password?(current_password)

    flash.now[:danger] = t(".wrong_password")
    render :edit, status: :unprocessable_entity
  end

  def set_user
    @user = current_user
    return if @user

    flash[:danger] = t ".not_found"
    redirect_to root_url
  end

  def change_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
