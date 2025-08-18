class Admin::BookingsController < Admin::BaseController
  before_action :load_bookings, only: :index
  before_action :load_booking_by_id,
                only: %i(show update_status decline show_decline)
  # GET /admin/bookings
  def index; end

  # GET /admin/bookings/:id
  def show; end

  # PATCH /admin/bookings/:id/update_status
  def update_status
    ApplicationRecord.transaction do
      @booking.lock!
      @booking.update!(
        status: booking_params[:status],
        status_changed_by_id: current_user.id
      )
    end
    @booking.send_confirmation_email if @booking.status_confirmed?
    flash[:success] = t(".success")
    redirect_to admin_booking_path(@booking)
  rescue ActiveRecord::RecordInvalid => e
    handle_error_update_status e
  end

  # GET /admin/bookings/:id/show_decline
  def show_decline
    render :show_decline, layout: false
  end

  # PATCH /admin/bookings/:id/decline
  def decline
    ApplicationRecord.transaction do
      @booking.lock!
      @booking.update!(status: booking_params[:status],
                       decline_reason: booking_params[:decline_reason],
                       status_changed_by_id: current_user.id)
    end
    @booking.send_decline_email if @booking.status_declined?
    flash[:success] = t(".success")
    redirect_to admin_booking_path(@booking), status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    handle_decline_error e
  end

  private

  def handle_decline_error error
    flash.now[:danger] = error.record.errors.full_messages.to_sentence
    render :decline, layout: false, status: :unprocessable_entity
  end

  def handle_error_update_status error
    flash.now[:danger] = error.record.errors.full_messages.to_sentence
    render :show, status: :unprocessable_entity
  end

  def load_bookings
    @q = Booking.preload(Booking::ASSOCIATIONS_PRELOAD)
                .by_booking_id
                .with_total_guests
                .with_total_price
                .ransack(params[:q])

    scope = @q.result(distinct: true)

    @pagy, @bookings = pagy(scope, items: Settings.default.digit_10,
                            limit: Settings.default.digit_10)
  end

  def load_booking_by_id
    @bookings = Booking.preload(Booking::ASSOCIATIONS_PRELOAD)
                       .by_booking_id
                       .with_total_guests
                       .with_total_price
                       .with_total_requests
    @booking = @bookings.find_by(id: params[:id])
    return if @booking

    flash[:danger] = t("admin.bookings.not_found")
    redirect_to admin_bookings_path
  end

  def booking_params
    params.require(:booking).permit(Booking::UPDATE_PARAMS)
  end
end
