module SessionsHelper
  # Logs in the given user.
  def log_in user
    user.remember
    session[:user_id] = user.id
    session[:remember_token] = user.remember_token
    # co 3 cach de luu tru session_storage:
    # :cookie_store (default)
    # :cache_store
    # :active_record_store
    # hien tai session trong rails duoc luu o cookie (default)
    # session[:user_id] = user.id -> Rails ma hoa, ky va gan user.id vao cookie
    # trinh duyet se luu cookie do, khi request se gui kem len server
    # Rails giai ma va khoi phuc session[:user_id] de xu ly
    # LUU Y:
    # cookie toi da co 4KB khong nen luu du lieu lon
    # co the set thoi gian het han cho cookie
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    @current_user ||= find_user_from_session || find_user_from_cookies
  end

  def find_user_from_session
    user_id = session[:user_id]
    return if user_id.blank?

    user = User.find_by(id: user_id)
    user if user&.authenticated?(session[:remember_token])
  end

  def find_user_from_cookies
    user_id = cookies.signed[:user_id]
    return if user_id.blank?

    user = User.find_by(id: user_id)
    return unless user&.authenticated?(cookies[:remember_token])

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
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end
end
