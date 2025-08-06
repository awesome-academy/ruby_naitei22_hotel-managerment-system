class BookingsController < ApplicationController
  before_action :require_login, only: %i(index update)
  before_action :set_current_booking, only: %i(update)
  before_action :set_user, only: %i(index cancel)
  before_action :set_booking, only: %i(cancel)

  # GET (/:locale)/bookings(.:format)
  def index
    @bookings = @user.bookings
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

  # POST (/:locale)/rooms/:room_id/bookings(.:format)
  def cancel
    if @booking.status_draft? || @booking.status_pending?
      @booking.update(status: :cancelled)
      flash[:success] = t(".success")
    else
      flash[:alert] = t(".alert")
    end
    redirect_back fallback_location: user_bookings_path(@user)
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

  def set_user
    @user = User.find(params[:user_id] || current_user.id)
  end

  def set_booking
    @booking = @user.bookings.find(params[:id])
  end
end
