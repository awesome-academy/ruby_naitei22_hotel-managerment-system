class RequestsController < ApplicationController
  def cancel
    @request = Request.find(params[:id])
    if @request.status_pending? || @request.status_draft?
      @request.update(status: :cancelled)
      flash[:success] = t(".success")
    else
      flash[:alert] = t(".alert")
    end
    redirect_back fallback_location: user_bookings_path(current_user)
  end
end
