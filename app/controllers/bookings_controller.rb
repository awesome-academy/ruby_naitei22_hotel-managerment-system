class BookingsController < ApplicationController
  before_action :require_login,
                only: %i(index update current_booking confirm_booking)
  before_action :set_current_booking,
                only: %i(update current_booking confirm_booking)
  before_action :load_current_booking_data, only: %i(current_booking)
  before_action :load_booking, only: %i(destroy)

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
    redirect_to current_booking_bookings_path
  rescue StandardError => e
    flash[:danger] = e.message
    redirect_back fallback_location: root_path
  end

  # DELETE (/:locale)/bookings/:id(.:format)
  def destroy
    if @booking.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".failure")
    end

    redirect_to current_booking_bookings_path
  end

  # GET (/:locale)/bookings/current_booking(.:format)
  def current_booking
    render :current_booking
  end

  # PATCH (/:locale)/bookings/:id/confirm_booking(.:format)
  def confirm_booking
    overlaps = find_overlapping_requests

    if overlaps.blank?
      assign_booking_code_and_status
      flash[:success] = t("current_booking.confirm.success")
      redirect_to bookings_path
    else
      redirect_if_overlap(overlaps)
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

  def load_current_booking_data
    @current_booking = current_user.bookings
                                   .includes(
                                     requests: [
                                       {room: :room_type},
                                       {room_availability_requests:
                                       :room_availability}
                                     ]
                                   )
                                   .find_by(id: @current_booking.id)
    return if @current_booking

    flash[:warning] = t("bookings.not_found")
    redirect_to bookings_path
  end

  def load_booking
    @booking = current_user.bookings.find_by id: params[:id]
    return if @booking

    flash[:warning] = t("bookings.not_found")
    redirect_to root_path
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

  def redirect_if_overlap overlaps
    return unless overlaps.any?

    room_names = overlaps.map {|r| r.room.room_number}.uniq.join(", ")
    flash[:warning] =
      t("current_booking.confirm.overlap_with_rooms", rooms: room_names)
    redirect_to @current_booking
    true
  end

  def find_overlapping_requests
    @current_booking.requests.select do |req|
      Request
        .where(room_id: req.room_id)
        .where.not(id: req.id)
        .where.not(status: Booking::INVALID_STATUSES)
        .where("(check_in <= ? AND check_out >= ?)",
               req.check_out, req.check_in)
        .exists?
    end
  end

  def assign_booking_code_and_status
    ActiveRecord::Base.transaction do
      random_code = SecureRandom
                    .alphanumeric(Settings.bookings.code.digit_6).upcase
      @current_booking.update!(booking_code: random_code, status: :pending)

      @current_booking.requests.each do |request|
        request.update!(status: :pending)
      end
    end
  rescue StandardError => e
    flash[:danger] = e.message
  end
end
