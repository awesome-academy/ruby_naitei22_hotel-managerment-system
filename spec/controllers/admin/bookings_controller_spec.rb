require "rails_helper"

RSpec.describe Admin::BookingsController, type: :controller do
  let(:admin) { create(:user, role: :admin) }
  let(:user) { create(:user) }
  let(:room_type) { create(:room_type) }
  let(:room) { create(:room, room_type: room_type) }
  let(:booking) { create(:booking, user: user) }
  let(:request_record) do
    create(:request, booking: booking, room: room,
                    check_in: Date.today,
                    check_out: Date.today + 2.days)
  end
  let!(:guest) { create(:guest, request: request_record) }
  let!(:room_availability) { create(:room_availability, room: room, available_date: Date.today) }
  let!(:room_availability_request) do
    create(:room_availability_request, request: request_record,
                                      room_availability: room_availability)
  end

  before { sign_in admin }

  describe "GET #index" do
    before { get :index, params: { q: { booking_code_eq: booking.booking_code } } }

    it "assigns @bookings" do
      expect(assigns(:bookings)).to include(booking)
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    context "when booking exists" do
      before { get :show, params: { id: booking.id } }

      it "assigns @booking" do
        expect(assigns(:bookings).ids).to include(booking.id)
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when booking does not exist" do
      before { get :show, params: { id: 0 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_bookings_path)
      end

      it "sets danger flash" do
        expect(flash[:danger]).to eq I18n.t("admin.bookings.not_found")
      end
    end
  end
end
