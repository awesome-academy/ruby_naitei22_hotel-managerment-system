class RoomsController < ApplicationController
  def index
    @pagy, @rooms = pagy Room.includes(:room_type)
    filter_by_room_type
    filter_by_price_range
    sort_rooms
  end

  def show
    @room = Room.find(params[:id])
    @room_availability = @room.room_availabilities
    @reviews = @room.reviews.includes(:user)
  end

  def new; end

  def edit; end

  private

  def filter_by_room_type
    return if params[:room_type].blank?

    @rooms = @rooms.joins(:room_type).where(
      room_types: {name: params[:room_type]}
    )
  end

  def filter_by_price_range
    return if params[:price_range].blank?

    case params[:price_range]
    when "below_50"
      @rooms = @rooms.joins(:room_type).where("room_types.price < ?", 50)
    when "50_99"
      @rooms = @rooms.joins(:room_type).where(
        "room_types.price BETWEEN ? AND ?", 50, 99
      )
    when "100_200"
      @rooms = @rooms.joins(:room_type).where(
        "room_types.price BETWEEN ? AND ?", 100, 200
      )
    when "above_200"
      @rooms = @rooms.joins(:room_type).where("room_types.price > ?", 200)
    end
  end

  def sort_rooms
    case params[:sort_by]
    when "price_asc"
      @rooms = @rooms.sort_by_price_asc
    when "price_desc"
      @rooms = @rooms.sort_by_price_desc
    when "rating_desc"
      @rooms = @rooms.sort_by_rating_desc
    end
  end
end
