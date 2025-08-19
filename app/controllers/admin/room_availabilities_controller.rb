class Admin::RoomAvailabilitiesController < Admin::BaseController
  DEFAULT_DATE_RANGE = 7

  before_action :load_room_availabilities, only: :index
  before_action :load_room_availability, only: %i(edit update)

  # GET /admin/room_availabilities
  def index; end

  # GET /admin/room_availabilities/:id/edit
  def edit; end

  # PATCH /admin/room_availabilities/:id
  def update
    if @room_availability.update(room_availability_params)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  private

  def room_availability_params
    params.require(:room_availability)
          .permit(RoomAvailability::ROOM_AVAILABILITY_PARAMS)
  end

  def load_room_availabilities
    set_default_date_filter
    @q = build_room_availabilities_query
    scope = @q.result.ordered

    @pagy, @room_availabilities = pagy(scope, items: Settings.default.digit_10,
                                       limit: Settings.default.digit_10)
  end

  def load_room_availability
    @room_availability = RoomAvailability.find_by(id: params[:id])
    return if @room_availability

    flash[:danger] =
      t("admin.room_availabilities.load_room_availability.not_found")
    redirect_to admin_room_availabilities_path
  end

  def set_default_date_filter
    params[:q] ||= {}

    return if filter_date_present?

    params[:q][:available_date_gteq] = Date.current.to_s
    params[:q][:available_date_lteq] = (Date.current + DEFAULT_DATE_RANGE).to_s
  end

  def filter_date_present?
    params[:q][:available_date_gteq].present? ||
      params[:q][:available_date_lteq].present?
  end

  def build_room_availabilities_query
    RoomAvailability
      .preload(RoomAvailability::ASSOCIATIONS_PRELOAD)
      .ransack(params[:q])
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
