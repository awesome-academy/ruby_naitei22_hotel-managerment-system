module SessionsHelper
  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    current_user.present?
  end
end
