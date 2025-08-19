require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let!(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let!(:room_type) { create(:room_type) }
  let!(:room) { create(:room, room_type: room_type) }
  let!(:room_availability) { create(:room_availability, room: room) }
  let!(:request) { create(:request, booking: booking, room_availabilities: [room_availability]) }
  let!(:guest) { create(:guest, request: request) }
  let!(:booking) { create(:booking, user: user) }

  before { sign_in admin }

  describe "GET #index" do
    before { get :index }

    it "returns success" do
      expect(response).to have_http_status(:ok)
    end

    it "assigns @users" do
      expect(assigns(:users)).to include(user)
    end

    it "assigns @q" do
      expect(assigns(:q)).to be_a(Ransack::Search)
    end
  end

  describe "GET #show" do
    context "when user exists" do
      before { get :show, params: { id: user.id } }

      it "returns success" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns @user" do
        expect(assigns(:user)).to eq(user)
      end

      it "assigns @bookings" do
        expect(assigns(:bookings)).to include(booking)
      end

      it "assigns @q for bookings" do
        expect(assigns(:q)).to be_a(Ransack::Search)
      end
    end

    context "when user does not exist" do
      before { get :show, params: { id: 999_999 } }

      it "redirects to admin_users_path" do
        expect(response).to redirect_to(admin_users_path)
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to eq(I18n.t("admin.users.show.not_found"))
      end
    end
  end
end
