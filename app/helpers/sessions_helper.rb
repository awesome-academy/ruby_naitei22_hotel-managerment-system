module SessionsHelper
  REMEMBER_ME = "1".freeze

  # Logs in the given user.
  def log_in user
    user.remember
    session[:user_id] = user.id
    session[:remember_token] = user.remember_token
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    @current_user ||= find_user_from_cookies || find_user_from_session
  end

  def find_user_from_session
    user_id = session[:user_id]
    return if user_id.blank?

    user = User.find_by(id: user_id)
    user if user&.authenticated?(:remember, session[:remember_token])
  end

  def find_user_from_cookies
    user_id = cookies.signed[:user_id]
    return if user_id.blank?

    user = User.find_by(id: user_id)
    return unless user&.authenticated?(:remember, cookies[:remember_token])

    log_in(user)
    user
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    current_user.present?
  end

  # Logs out the current user.
  def log_out
    forget current_user
    reset_session
    @current_user = nil
  end

  # Remembers a user in a persistent session.
  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forgets a persistent session.
  def forget user
    return if user.nil?

    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  # Returns true if the given user is the current user.
  def current_user? user
    user == current_user
  end

  def authenticated_user user
    store_location
    reset_session
    remember_or_forget user
    log_in user
    redirect_back_or user
  end

  def check_activation user
    return true if user.activated?

    flash[:warning] = t("users.not_activated")
    redirect_to root_url, status: :see_other
    false
  end

  def remember_or_forget user
    if params[:session][:remember_me] == REMEMBER_ME
      remember user
    else
      forget user
    end
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
