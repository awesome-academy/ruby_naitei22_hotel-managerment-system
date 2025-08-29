require "rails_helper"

RSpec.describe "Rooms", type: :request do
  let!(:room_type) { create(:room_type) }
  let!(:room) { create(:room, room_type: room_type) }

  describe "GET /rooms" do
    before { get rooms_path }

    it "returns success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns rooms" do
      expect(assigns(:rooms)).to include(room)
    end
  end

  describe "GET /rooms/:id" do
    context "when room exists" do
      before { get room_path(room, locale: I18n.locale) }

      it "returns success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns amenities" do
        expect(assigns(:amenities)).to eq(room.amenities)
      end

      it "assigns approved reviews" do
        expect(assigns(:reviews)).to match_array(
          room.reviews.where(review_status: :approved)
        )
      end

      it "assigns available dates" do
        expect(assigns(:available_dates)).to eq(room.available_dates)
      end
    end

    context "when room does not exist" do
      before { get room_path(id: -1) }

      it "redirects to rooms index" do
        expect(response).to redirect_to(rooms_path)
      end

      it "sets warning flash" do
        expect(flash[:warning]).to eq(I18n.t("rooms.not_found"))
      end
    end
  end

  describe "GET /rooms/:id/calculate_price" do
    context "with valid dates" do
      let!(:availability1) { create(:room_availability, room: room, available_date: Date.today, price: 100) }
      let!(:availability2) { create(:room_availability, room: room, available_date: Date.today + 1, price: 200) }

      before do
        get calculate_price_room_path(room, locale: I18n.locale), params: {
          check_in: Date.today.to_s,
          check_out: (Date.today + 1).to_s
        }
      end

      it "returns success status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns success in JSON" do
        expect(JSON.parse(response.body)["success"]).to be true
      end

      it "returns total price" do
        expect(JSON.parse(response.body)["total_price"]).to eq("300.0")
      end

      it "returns nights count" do
        expect(JSON.parse(response.body)["nights"]).to eq(1)
      end
    end

    context "with invalid dates" do
      before do
        get calculate_price_room_path(room, locale: I18n.locale), params: {
          check_in: "2025-10-10",
          check_out: "2025-10-05" # check_out < check_in
        }
      end

      it "returns unprocessable_entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error in JSON" do
        expect(JSON.parse(response.body)["success"]).to be false
      end
    end

    context "with exception" do
      before do
        allow_any_instance_of(Room).to receive(:room_availabilities).and_raise(StandardError, "boom")
        get calculate_price_room_path(room, locale: I18n.locale), params: {
          check_in: Date.today.to_s,
          check_out: (Date.today + 1).to_s
        }
      end

      it "returns internal_server_error" do
        expect(response).to have_http_status(:internal_server_error)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("boom")
      end
    end
  end
end
