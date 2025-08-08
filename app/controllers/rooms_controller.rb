class RoomsController < ApplicationController
  # GET (/:locale)/rooms(.:format)
  def index
    @pagy, @rooms = pagy(
      Room.includes(:room_type)
        .by_room_type(params[:room_type])
        .by_price_range(params[:price_range])
        .sorted(params[:sort_by])
    )
  end

  # GET /rooms/show(.:format)
  def show; end

  # GET /rooms/new(.:format)
  def new; end

  # GET /rooms/edit(.:format)
  def edit; end
end
