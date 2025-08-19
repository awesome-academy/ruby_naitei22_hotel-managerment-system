class Admin::RoomTypesController < Admin::BaseController
  before_action :load_room_type, only: %i(edit update destroy)

  # GET /admin/room_types
  def index
    @q = RoomType.ransack(params[:q])
    @room_types = @q.result

    scope = @q.result(distinct: true)

    @pagy, @room_types = pagy(scope, items: Settings.default.digit_10,
                            limit: Settings.default.digit_10)
  end

  # GET /admin/room_types/new
  def new
    @room_type = RoomType.new
  end

  # POST /admin/room_types
  def create
    @room_type = RoomType.new(room_type_params)
    if @room_type.save
      handle_successful_creation
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
      flash[:danger] = @room_type.errors.full_messages.to_sentence
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

    flash[:danger] = t("admin.room_types.load_room_type.not_found")
    redirect_to admin_room_types_path
  end

  def handle_successful_creation
    flash[:success] = t(".success_message")
    redirect_to admin_room_types_path
  end

  def handle_failed_creation
    flash.now[:danger] = t(".error_message")
    render :new, status: :unprocessable_entity
  end

  def handle_successful_update
    flash[:success] = t(".success_message")
    redirect_to admin_room_types_path
  end

  def handle_failed_update
    flash.now[:danger] = t(".error_message")
    render :edit, status: :unprocessable_entity
  end
end
