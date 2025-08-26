class ApplicationController < ActionController::Base
  PERMIT_KEY = %i(name phone).freeze

  protect_from_forgery with: :exception
  include Pagy::Backend

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: PERMIT_KEY)
    devise_parameter_sanitizer.permit(:account_update, keys: PERMIT_KEY)
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
