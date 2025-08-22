module LoginHelpers
  def log_in user
    user.remember
    session[:user_id] = user.id
    session[:remember_token] = user.remember_token
  end
  def log_out
    current_user&.forget
    session.delete(:user_id)
    session.delete(:remember_token)
  end
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  def logged_in?
    current_user.present?
  end
  RSpec.configure do |config|
    config.include LoginHelpers, type: :controller
  end
end
