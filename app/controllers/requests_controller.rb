class RequestsController < ApplicationController
  before_action :load_request, only: %i(destroy)

  # DELETE (/:locale)/requests/:id(.:format)
  def destroy
    if @request.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".failure")
    end

    redirect_to current_booking_bookings_path
  end

  private

  def load_request
    @request = Request.find_by id: params[:id]
    return if @request

    flash[:warning] = t(".not_found")
    redirect_to root_path
  end
end
