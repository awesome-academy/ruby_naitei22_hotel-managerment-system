class Admin::BaseController < ApplicationController
  layout "admin"
  check_authorization

  authorize_resource :admin, class: false
end
