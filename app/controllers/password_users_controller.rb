class PasswordUsersController < ApplicationController
  before_action :set_user, only: %i(edit update)
  before_action :check_authen, only: :update

  # GET (/:locale)/users/:user_id/password_user/edit(.:format)
  def edit; end

  # PUT (/:locale)/users/:user_id/password_user(.:format)
  def update
    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      flash[:success] = t(".success")
      redirect_to user_password_user_path(@user)
    else
      flash.now[:danger] = t(".wrong_password")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
    return if @user

    flash[:danger] = t ".not_found"
    redirect_to root_url
  end

  def password_params
    params.require(:user).permit(User::USER_PERMIT_UPDATE_PASSWORD)
  end

  def check_authen
    current_password = params.dig(:user, :current_password)
    return if @user&.valid_password?(current_password)

    flash.now[:danger] = t(".invalid_current_password")
    render :edit, status: :unprocessable_entity
  end
end
