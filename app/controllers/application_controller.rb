class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Pagy::Backend

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for resource
    if resource.role_admin?
      admin_dashboard_path
    else
      stored_location_for(resource) || root_path
    end
  end

  rescue_from CanCan::AccessDenied do |_exception|
    respond_to do |format|
      format.html do
        redirect_to unauthorized_path
      end
      format.json do
        render json: {error: "Access Denied"}, status: :forbidden
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone])
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
