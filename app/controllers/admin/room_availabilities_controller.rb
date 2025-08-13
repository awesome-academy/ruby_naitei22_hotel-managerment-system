class Admin::RoomAvailabilitiesController < Admin::BaseController
  before_action :load_room_availabilities, only: :index

  # GET /admin/room_availabilities
  def index; end

  private

  def load_room_availabilities
    set_default_date_filter
    @q = build_room_availabilities_query
    scope = @q.result.ordered

    @pagy, @room_availabilities = pagy(scope, items: Settings.default.digit_10,
                                       limit: Settings.default.digit_10)
  end

  def set_default_date_filter
    return if params.dig(:q, :available_date_eq).present?

    params[:q] ||= {}
    params[:q][:available_date_eq] = Date.current.to_s
  end

  def build_room_availabilities_query
    RoomAvailability
      .preload(RoomAvailability::ASSOCIATIONS_PRELOAD)
      .ransack(params[:q])
  end
end
