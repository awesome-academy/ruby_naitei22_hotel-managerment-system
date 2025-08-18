class Admin::RoomsController < Admin::BaseController
  before_action :load_room, only: %i(edit update)
  before_action :load_room_types_and_amenities, only: %i(new edit create update)

  # GET /admin/rooms/new
  def new
    @room = Room.new
  end

  # GET /admin/rooms/:id/edit
  def edit; end

  # POST /admin/rooms
  def create
    @room = Room.new room_params

    if @room.save
      handle_successful_creation
    else
      handle_failed_creation
    end
  end

  # PATCH /admin/rooms/:id
  def update
    if @room.update(room_params)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  # DELETE /admin/rooms/:id/remove_image
  def remove_image
    @image = ActiveStorage::Attachment.find_by(id: params[:image_id])
    @image&.purge_later
    redirect_back(fallback_location: request.referer)
  end

  private

  def room_params
    params.require(:room).permit(*Room::ROOM_PARAMS)
  end

  def load_room_types_and_amenities
    @room_types = RoomType.all
    @amenities = Amenity.all
  end

  def load_room
    @room = Room.find_by(id: params[:id])
    return if @room

    flash[:danger] = t("admin.rooms.load_room.not_found")
    redirect_to admin_room_availabilities_path
  end

  def handle_successful_creation
    flash[:success] = t(".success")
    redirect_to admin_room_availabilities_path
  end

  def handle_failed_creation
    flash.now[:danger] = t(".failure")
    render :new, status: :unprocessable_entity
  end

  def handle_successful_update
    flash[:success] = t(".success")
    redirect_to admin_room_availabilities_path
  end

  def handle_failed_update
    flash.now[:danger] = t(".failure")
    render :edit, status: :unprocessable_entity
  end
end
