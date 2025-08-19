module Admin::RoomAvailabilitiesHelper
  # Helper for status options in room availabilities search
  def room_availability_status_options
    [
      [t("admin.room_availabilities.filter.all"), ""],
      [t("admin.room_availabilities.filter.available"), true],
      [t("admin.room_availabilities.filter.unavailable"), false]
    ]
  end

  # Helper for admin to choose when edit room availabilities
  def availability_status_options
    [
      [t("admin.room_availabilities.filter.available"), true],
      [t("admin.room_availabilities.filter.unavailable"), false]
    ]
  end
end
