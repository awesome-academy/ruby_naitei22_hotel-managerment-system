class PasswordsController < ApplicationController
  before_action :set_user, only: %i(edit update)
  def edit; end

  def update
    if @user.authenticate(params[:user][:current_password])
      if @user.update(password_params)
        flash[:success] = t(".success")
        redirect_to user_password_path(@user)
      end
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
    params.require(:user).permit(:password, :password_confirmation)
  end
end
