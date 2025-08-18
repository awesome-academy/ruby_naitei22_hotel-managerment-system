class BookingsController < ApplicationController
  before_action :require_login, only: %i(index update)
  before_action :set_current_booking, only: %i(update)

  # GET (/:locale)/bookings(.:format)
  def index
    @bookings = current_user.bookings.includes(:requests)
  end

  # PATCH (/:locale)/rooms/:room_id/bookings/:id(.:format)
  def update
    ActiveRecord::Base.transaction do
      @current_booking.update!(booking_params)
      create_room_availability_requests(@current_booking)
    end

    flash[:success] = t("bookings.requests.success")
    redirect_to bookings_path
  rescue StandardError => e
    flash[:danger] = e.message
    redirect_back fallback_location: root_path
  end

  private

  def booking_params
    params.require(:booking).permit(
      requests_attributes: Request::REQUEST_PERMIT
    )
  end

  def set_current_booking
    @current_booking = current_user.bookings.find_or_create_by(status: :draft)
  end

  def require_login
    return if logged_in?

    flash[:danger] = t(".card.need_login")
    redirect_back(fallback_location: root_path)
  end

  def create_room_availability_requests booking
    req = booking.requests.last
    return unless req&.room

    booking_dates = (req.check_in.to_date..req.check_out.to_date).to_a

    room_avails = req.room.room_availabilities
                     .where(available_date: booking_dates)

    room_avails.each do |avail|
      req.room_availability_requests.create!(
        room_availability: avail
      )
    end
  end
end
