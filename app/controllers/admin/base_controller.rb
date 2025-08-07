class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    return if current_user&.role_admin?

    flash[:alert] = t("admin.base.unauthorized_access")
    redirect_to root_path
  end
end
