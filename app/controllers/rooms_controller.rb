class RoomsController < ApplicationController
  before_action :load_room, only: %i(show)

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
    @room_availability = @room.room_availabilities
    @reviews = @room.reviews.includes(:user)
  end

  private

  def load_room
    @room = Room.find_by id: params[:id]
    return if @room

    flash[:warning] = t("rooms.not_found")
    redirect_to root_path
  end
end
