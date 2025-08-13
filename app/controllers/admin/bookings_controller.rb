class Admin::BookingsController < Admin::BaseController
  before_action :load_bookings, only: :index
  # GET /admin/bookings
  def index; end

  private

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
end
