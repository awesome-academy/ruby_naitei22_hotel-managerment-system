class Admin::GuestsController < Admin::BaseController
  before_action :load_request
  before_action :check_access_guest, only: %i(new create edit update destroy)
  before_action :load_guest, only: %i(edit update destroy)

  # GET /admin/bookings/:booking_id/requests/:request_id/guests/new
  def new
    @guest = @request.guests.build
  end

  # POST /admin/bookings/:booking_id/requests/:request_id/guests
  def create
    @guest = @request.guests.build(guest_params)
    if @guest.save
      flash[:success] = t(".success")
      redirect_to admin_booking_request_path(@request.booking, @request),
                  status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/bookings/:booking_id/requests/:request_id/guests/:id/edit
  def edit; end

  # PATCH /admin/bookings/:booking_id/requests/:request_id/guests/:id
  def update
    if @guest.update(guest_params)
      flash.now[:success] = t(".success")
      render :edit, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/bookings/:booking_id/requests/:request_id/guests/:id
  def destroy
    if @guest.destroy
      flash[:success] = t(".success")
      redirect_to admin_booking_request_path(@request.booking, @request),
                  status: :see_other
    else
      flash[:danger] = t(".error")
      redirect_to admin_booking_request_path(@request.booking, @request),
                  status: :unprocessable_entity
    end
  end

  private

  def load_request
    @request = Request.find_by(id: params[:request_id])
    @booking = @request&.booking
    return if @request

    flash[:danger] = t(".request_not_found")
    redirect_to admin_bookings_path
  end

  def load_guest
    @guest = Guest.find_by(id: params[:id])
    return if @guest

    flash[:danger] = t(".guest_not_found")
    redirect_to admin_booking_request_path(@request.booking_id, @request)
  end

  def guest_params
    params.require(:guest).permit(Guest::GUEST_PARAMS)
  end

  def check_access_guest
    return if @request.status_checked_in?

    flash[:danger] = t("admin.guests.request_not_checked_in")
    redirect_to admin_booking_request_path(@request.booking_id, @request)
  end
end
