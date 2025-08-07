class Admin::DashboardController < Admin::BaseController
  # GET /admin/dashboard
  def index
    @users_count = User.count
    @bookings_count = Booking.count
    @rooms_count = Room.count
    @reviews_count = Review.count
  end
end
