class Admin::RequestsController < Admin::BaseController
  before_action :load_request, only: %i(show update)
  before_action :validate_check_out, only: :update

  # GET /admin/bookings/:booking_id/requests/:id
  def show; end

  # PATCH /admin/bookings/:booking_id/requests/:id
  def update
    if @request.update(request_params)
      flash[:success] = t(".success")
      redirect_to admin_booking_request_path(@request.booking, @request)
    else
      flash.now[:danger] = t(".failed")
      render :show, status: :unprocessable_entity
    end
  end

  private
  def load_request
    @request = Request
               .preload(Request::ASSOCIATIONS_REQUEST_PRELOAD)
               .where(booking_id: params[:booking_id])
               .find_by(id: params[:id])

    return if @request

    flash[:danger] = t("admin.requests.not_found_request")
    redirect_to admin_booking_path(booking_id)
  end

  def request_params
    params.require(:request).permit(:status)
  end

  def validate_check_out
    new_status = request_params[:status].to_s

    unless new_status == Request::CHECKED_OUT_STATUS && !@request.guests.exists?
      return
    end

    flash[:danger] = t(".validate_check_out")
    render :show, status: :unprocessable_entity
  end
end
