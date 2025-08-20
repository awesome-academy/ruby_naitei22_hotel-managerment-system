class PasswordResetsController < ApplicationController
  before_action :load_user,
                :valid_user,
                :check_expiration,
                only: %i(edit update)
  before_action :load_user_by_email_param, only: :create

  # GET (/:locale)/password_resets/new(.:format)
  def new; end

  # GET (/:locale)/password_resets/:id/edit(.:format)
  def edit; end

  # POST (/:locale)/password_resets(.:format)
  def create
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".email_sent"
      redirect_to root_path
    else
      flash.now[:danger] = t ".email_not_found"
      render :new, status: :unprocessable_entity
    end
  end

  # PUT (/:locale)/password_resets/:id(.:format)
  def update
    if @user.update user_params.merge(reset_digest: nil)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  private

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t ".not_found"
    redirect_to root_url
  end

  def valid_user
    return if @user&.activated? && @user&.authenticated?(:reset, params[:id])

    flash[:danger] = t ".invalid_user"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".expired"
    redirect_to new_password_reset_url
  end

  def user_params
    params.require(:user).permit User::USER_PERMIT_PASSWORD_RESET
  end

  def load_user_by_email_param
    email = params.dig(:password_reset, :email)&.downcase
    @user = User.find_by(email:)
  end

  def handle_successful_update
    log_in @user
    flash[:success] = t(".success")
    redirect_to root_path
  end

  def handle_failed_update
    flash.now[:danger] = t(".failure")
    render :edit, status: :unprocessable_entity
  end
end
