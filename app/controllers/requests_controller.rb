class RequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_request, only: %i(destroy cancel)
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

  def load_request
    @request = Request.find_by id: params[:id]
    return if @request

    flash[:warning] = t(".not_found")
    redirect_to root_path
  end

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
