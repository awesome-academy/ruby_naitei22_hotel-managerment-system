class RoomsController < ApplicationController
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
end
