class Admin::RoomsController < Admin::BaseController
  before_action :load_room, only: %i(show edit update destroy)
  before_action :load_room_types_and_amenities, only: %i(new edit create update)
  before_action :set_default_date_filter, only: %i(show)

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

  # GET /admin/rooms/:id
  def show
    @q = @room.room_availabilities.ransack(params[:q])
    @availability = @q.result.first
    @reviews = @room.reviews.includes(:user)
  end

  # DELETE /admin/rooms/:id
  def destroy
    if @room.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".failure")
    end
    redirect_to admin_room_availabilities_path
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

  def set_default_date_filter
    return if params.dig(:q, :available_date_eq).present?

    params[:q] ||= {}
    params[:q][:available_date_eq] = Date.current.to_s
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
