class Admin::UsersController < Admin::BaseController
  before_action :load_user, only: :show
  before_action :load_bookings, only: :show

  # GET /admin/users
  def index
    @q = User.with_total_created_bookings.ransack(params[:q])
    scope = @q.result(distinct: true).recent
    @pagy, @users = pagy(scope, items: Settings.default.digit_10,
                               limit: Settings.default.digit_10)
  end

  # GET /admin/users/:id
  def show; end

  private

  def load_user
    @user = User.find_by(id: params[:id])

    return if @user

    flash[:danger] = t(".not_found")
    redirect_to admin_users_path
  end

  def load_bookings
    @q = Booking.preload(Booking::ASSOCIATIONS_PRELOAD)
                .by_booking_id
                .with_total_guests
                .with_total_price
                .where(user_id: params[:id])
                .ransack(params[:q])

    scope = @q.result(distinct: true)

    @pagy, @bookings = pagy(scope, items: Settings.default.digit_10,
                            limit: Settings.default.digit_10)
  end
end
