class RoomsController < ApplicationController
  before_action :load_room, only: %i(show)
  before_action :set_current_booking, only: %i(show)

  # GET (/:locale)/rooms(.:format)
  def index
    @pagy, @rooms = pagy(
      Room.includes(:room_type)
      .available_on(params[:check_in], params[:check_out])
      .by_room_type(params[:room_type])
      .by_price_range(params[:price_range])
      .sorted(params[:sort_by])
    )
  end

  # GET (/:locale)/rooms/id
  def show
    @amenities = @room.amenities
    @reviews = @room.reviews.includes(:user).distinct
    @available_dates = @room.available_dates
  end

  # GET (/:locale)/rooms/:id/calculate_price(.:format)
  def calculate_price
    room = Room.find(params[:id])

    check_in  = parse_date(params[:check_in])
    check_out = parse_date(params[:check_out])

    if check_in && check_out && check_out >= check_in
      nights = (check_out - check_in).to_i
      total_price = room.room_availabilities
                        .where(available_date: check_in..check_out)
                        .sum(:price)

      render json: {total_price:, nights:}
    else
      render json: {total_price: nil, nights: nil}
    end
  end

  private

  def load_room
    @room = Room.find_by id: params[:id]
    return if @room

    flash[:warning] = t("rooms.not_found")
    redirect_to root_path
  end

  def set_current_booking
    return unless logged_in?

    @current_booking = current_user.bookings.find_or_create_by(status: :draft)
  end

  def parse_date date_str
    Date.parse(date_str)
  rescue StandardError
    nil
  end
end
