class ErrorsController < ApplicationController
  def unauthorized
    render :unauthorized, status: :unauthorized
  end

  def not_found
    render :not_found, status: :not_found
  end
end
