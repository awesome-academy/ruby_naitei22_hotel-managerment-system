require "rails_helper"

RSpec.describe RoomsController, type: :controller do
  let(:user) { create(:user) }
  let!(:room_type) { create(:room_type) }
  let!(:room) do
    create(
      :room,
      room_type: room_type,
      price: 100,
      price_from_date: Date.today,
      price_to_date: Date.today + 15.days
    )
  end

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    it "assigns rooms collection" do
      expect(assigns(:rooms)).to include(room)
    end

    it "renders index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    context "when room exists" do
      before { get :show, params: { id: room.id } }

      it "assigns the requested room" do
        expect(assigns(:room)).to eq(room)
      end

      it "assigns available_dates" do
        expect(assigns(:available_dates)).to be_an(Array)
      end

      it "renders show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when room does not exist" do
      before { get :show, params: { id: -1 } }

      it "redirects to root" do
        expect(response).to redirect_to(root_path)
      end

      it "sets warning flash" do
        expect(flash[:warning]).to eq(I18n.t("rooms.not_found"))
      end
    end
  end

  describe "GET #calculate_price" do
    let!(:ra_day1) { room.room_availabilities.find_by(available_date: Date.today + 10.days) }
    let!(:ra_day2) { room.room_availabilities.find_by(available_date: Date.today + 11.days) }

    before do
      ra_day1.update!(price: 100)
      ra_day2.update!(price: 120)
    end

    context "with valid dates" do
      let(:check_in)  { (Date.today + 10.days).to_s }
      let(:check_out) { (Date.today + 11.days).to_s }

      before { get :calculate_price, params: { id: room.id, check_in: check_in, check_out: check_out }, format: :json }

      it "returns success true" do
        parsed = JSON.parse(response.body)
        expect(parsed["success"]).to be true
      end

      it "calculates total price" do
        parsed = JSON.parse(response.body)
        expected_price = ra_day1.price + ra_day2.price
        expect(parsed["total_price"].to_f).to eq(expected_price.to_f)
      end

      it "returns status ok" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid date range" do
      before do
        get :calculate_price, params: {
          id: room.id,
          check_in: "2025-01-10",
          check_out: "2025-01-05"
        }, format: :json
      end

      it "returns error json" do
        parsed = JSON.parse(response.body)
        expect(parsed["success"]).to be false
        expect(parsed["error"]).to eq(I18n.t("bookings.card.error_price"))
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when exception occurs" do
      before do
        allow_any_instance_of(Room)
          .to receive_message_chain(:room_availabilities, :where, :sum)
          .and_raise(StandardError.new("boom"))

        get :calculate_price, params: {
          id: room.id,
          check_in: Date.today.to_s,
          check_out: (Date.today + 1).to_s
        }, format: :json
      end

      it "returns internal_server_error status" do
        expect(response).to have_http_status(:internal_server_error)
      end

      it "returns error message" do
        parsed = JSON.parse(response.body)
        expect(parsed["success"]).to be false
        expect(parsed["error"]).to eq("boom")
      end
    end
  end
end
