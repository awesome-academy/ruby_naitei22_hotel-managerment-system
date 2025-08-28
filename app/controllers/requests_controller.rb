class RequestsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource

  before_action :check_request_status, only: %i(cancel)

  # DELETE (/:locale)/requests/:id(.:format)
  def destroy
    if @request.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".failure")
    end

    redirect_to current_booking_bookings_path
  end

  # PUT (/:locale)/users/:user_id/requests/:id/cancel(.:format)
  def cancel
    handle_cancel_request
    redirect_back fallback_location: user_bookings_path(current_user)
  end

  private

  def handle_cancel_request
    if @request.update(status: :cancelled)
      flash[:success] = t(".cancel.success")
    else
      flash[:error] = t(".cancel.failure")
    end
  end

  def check_request_status
    return if @request.status_pending?

    flash[:alert] = t(".alert")
    redirect_back fallback_location: user_bookings_path(current_user)
  end
end
