class SessionsController < ApplicationController
  REMEMBER_ME = "1".freeze

  def new; end

  def create
    user = User.find_by(email: params.dig(:session, :email)&.downcase)

    if user&.authenticate params.dig(:session, :password)
      # Log the user in and redirect to the user's show page.
      log_in user

      if params.dig(:session, :remember_me) == REMEMBER_ME
        remember(user) # tao token luu vao cookie
      end
      redirect_to user, status: :see_other
    else
      # Create an error
      flash.now[:danger] = t("login.failure")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end
end
