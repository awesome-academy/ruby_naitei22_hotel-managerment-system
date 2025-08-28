class ApplicationController < ActionController::Base
  PERMIT_KEY = %i(name phone).freeze

  protect_from_forgery with: :exception
  include Pagy::Backend

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json {head :forbidden}
      format.html do
        flash[:danger] = cancan_error_message(exception)
        redirect_back(fallback_location: root_path)
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: PERMIT_KEY)
    devise_parameter_sanitizer.permit(:account_update, keys: PERMIT_KEY)
  end

  private

  def cancan_error_message exception
    action = exception.action
    subject_key =
      case s = exception.subject
      when Symbol then s.to_s
      when Class  then s.model_name.i18n_key.to_s
      else
        s.respond_to?(:model_name) ? s.model_name.i18n_key.to_s : "all"
      end

    I18n.t("cancan.permission_denied",
           action: I18n.t("actions.#{action}", default: action),
           resource: I18n.t("resources.#{subject_key}", default: subject_key))
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
