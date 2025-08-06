class AccountActivationsController < ApplicationController
  before_action :load_user, only: :edit
  before_action :check_not_activated, only: :edit
  before_action :check_valid_token, only: :edit

  # GET /account_activations/:id/edit(.:format)
  def edit
    @user.activate
    log_in @user
    flash[:success] = t(".success")
    redirect_to root_url
  end

  private

  def check_not_activated
    return unless @user.activated

    flash[:danger] = t("users.activated")
    redirect_to root_url
  end

  def check_valid_token
    return if @user.authenticated?(:activation, params[:id])

    flash[:danger] = t(".invalid")
    redirect_to root_url
  end

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:warning] = t("users.not_found")
    redirect_to root_path
  end
end
