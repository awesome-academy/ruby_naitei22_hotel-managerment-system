module Admin::BookingsHelper
  def booking_status_options
    [
      [t("admin.bookings.filter.all"), ""],
      [t("admin.bookings.filter.draft"), Booking.statuses[:draft]],
      [t("admin.bookings.filter.pending"), Booking.statuses[:pending]],
      [t("admin.bookings.filter.confirmed"), Booking.statuses[:confirmed]],
      [t("admin.bookings.filter.declined"), Booking.statuses[:declined]],
      [t("admin.bookings.filter.cancelled"), Booking.statuses[:cancelled]],
      [t("admin.bookings.filter.completed"), Booking.statuses[:completed]]
    ]
  end
end
