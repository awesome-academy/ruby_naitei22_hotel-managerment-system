require "rails_helper"

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    # Prepare data and then compare with actual counts to avoid brittle expectations
    before do
      # Create data that contributes to counters
      create_list(:user, 2) # additional users
      create_list(:room_type, 2) # indirect, just to have data
      create_list(:room, 3) # rooms
      create_list(:booking, 2) # each booking has a user association
      create_list(:review, 4) # each review creates user + request(+booking+user) + approved_by(admin)

      @expected_users_count   = User.count
      @expected_bookings_count = Booking.count
      @expected_rooms_count    = Room.count
      @expected_reviews_count  = Review.count

      get :index
    end

    it "assigns users count" do
      expect(assigns(:users_count)).to eq(@expected_users_count)
    end

    it "assigns bookings count" do
      expect(assigns(:bookings_count)).to eq(@expected_bookings_count)
    end

    it "assigns rooms count" do
      expect(assigns(:rooms_count)).to eq(@expected_rooms_count)
    end

    it "assigns reviews count" do
      expect(assigns(:reviews_count)).to eq(@expected_reviews_count)
    end

    it "renders index template" do
      expect(response).to render_template(:index)
    end

    it "returns success status" do
      expect(response).to have_http_status(:ok)
    end
  end
end
