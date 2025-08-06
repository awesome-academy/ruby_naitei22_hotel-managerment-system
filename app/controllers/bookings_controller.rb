class BookingsController < ApplicationController
  before_action :require_login, only: %i(index update)
  before_action :set_current_booking, only: %i(update)

  # GET (/:locale)/bookings(.:format)
  def index
    @bookings = current_user.bookings.includes(:requests)
  end

  # PATCH (/:locale)/rooms/:room_id/bookings/:id(.:format)
  def update
    if @current_booking.update(booking_params)
      flash[:success] = t("bookings.requests.success")
      redirect_to bookings_path
    else
      flash[:danger] = @current_booking.errors.full_messages.to_sentence
      redirect_back fallback_location: root_path
    end
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
end
