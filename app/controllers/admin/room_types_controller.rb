class Admin::RoomTypesController < Admin::BaseController
  before_action :load_room_type, only: %i(edit update destroy)

  # GET /admin/room_types
  def index
    @q = RoomType.ransack(params[:q])
    @room_types = @q.result
  end

  # GET /admin/room_types/new
  def new
    @room_type = RoomType.new
  end

  # POST /admin/room_types
  def create
    @room_type = RoomType.new(room_type_params)
    if @room_type.save
      handle_sucessful_creation
    else
      handle_failed_creation
    end
  end

  # GET /admin/room_types/:id/edit
  def edit; end

  # PATCH /admin/room_types/:id
  def update
    if @room_type.update(room_type_params)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  # DELETE /admin/room_types/:id
  def destroy
    if @room_type.destroy
      flash[:success] = t(".success_message")
    else
      flash[:error] = t(".error_message")
    end
    redirect_to admin_room_types_path
  end

  private

  def room_type_params
    params.require(:room_type).permit RoomType::ROOM_TYPE_PARAMS
  end

  def load_room_type
    @room_type = RoomType.find_by(id: params[:id])
    return if @room_type

    flash[:warning] = t("admin.room_types.load_room_type.not_found")
    redirect_to admin_room_types_path
  end

  def handle_sucessful_creation
    flash[:success] = t(".success_message")
    redirect_to admin_room_types_path
  end

  def handle_failed_creation
    flash.now[:error] = t(".error_message")
    render :new
  end

  def handle_successful_update
    flash[:success] = t(".success_message")
    redirect_to admin_room_types_path
  end

  def handle_failed_update
    flash.now[:error] = t(".error_message")
    render :edit
  end
end
