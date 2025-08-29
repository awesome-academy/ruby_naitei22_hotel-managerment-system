require "rails_helper"

RSpec.describe Admin::RoomAvailabilitiesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:room_type) { create(:room_type) }
  let!(:room1) { create(:room, room_type: room_type, room_number: "A101", price_from_date: Date.today, price_to_date: Date.today + 10.days, price: 150) }
  let!(:room2) { create(:room, room_type: room_type, room_number: "A102", price_from_date: Date.today, price_to_date: Date.today + 10.days, price: 300) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    context "when no params provided" do
      let!(:room_availability_today_room1) { room1.room_availabilities.find_by(available_date: Date.today) }
      let!(:room_availability_today_room2) { room2.room_availabilities.find_by(available_date: Date.today) }
      let!(:room_availability_middle_range) { room1.room_availabilities.find_by(available_date: Date.today + 3.days) }
      let!(:room_availability_outside_range) { room1.room_availabilities.find_by(available_date: Date.today + 10.days) }

      before { get :index }

      it "returns room availabilities within default date range only" do
        dates = assigns(:room_availabilities).map(&:available_date)
        expect(dates).to all(satisfy { |d| d >= Date.today && d <= Date.today + 7 })
      end

      it "excludes room availabilities outside default date range" do
        expect(assigns(:room_availabilities)).not_to include(room_availability_outside_range)
      end

      it "orders results by available date then room number" do
        same_day_records = assigns(:room_availabilities).select { |ra| ra.available_date == Date.today }
        expect(same_day_records.map { |ra| ra.room.room_number }).to eq(%w(A101 A102))
      end

      it "renders index template" do
        expect(response).to render_template(:index)
      end
    end
  end

  describe "GET #edit" do
    let!(:room_availability) { room1.room_availabilities.find_by(available_date: Date.today) }

    context "when room availability exists" do
      before { get :edit, params: { id: room_availability.id } }

      it "assigns the requested room availability to @room_availability" do
        expect(assigns(:room_availability)).to eq(room_availability)
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end
    end

    context "when room availability does not exist" do
      before { get :edit, params: { id: -1 } }

      it "redirects to room availabilities index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end

      it "displays not found error message" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_availabilities.load_room_availability.not_found"))
      end
    end
  end

  describe "PATCH #update" do
    let!(:room_availability) { room1.room_availabilities.find_by(available_date: Date.today) }

    context "when update is successful" do
      before { patch :update, params: { id: room_availability.id, room_availability: { is_available: false } } }

      it "updates the room availability record" do
        room_availability.reload
        expect(room_availability.is_available).to be_falsey
      end

      it "displays success message" do
        expect(flash[:success]).to eq(I18n.t("admin.room_availabilities.update.success"))
      end

      it "redirects to room availabilities index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end
    end

    context "when update fails due to invalid data" do
      before { patch :update, params: { id: room_availability.id, room_availability: { is_available: nil } } }

      it "does not update the room availability record" do
        room_availability.reload
        expect(room_availability.is_available).to be_truthy
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays error message" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.room_availabilities.update.failure"))
      end
    end

    context "when room availability record does not exist" do
      before { patch :update, params: { id: -1, room_availability: { is_available: false } } }

      it "redirects to room availabilities index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end

      it "displays not found error message" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_availabilities.load_room_availability.not_found"))
      end
    end

    context "when attempting to update unauthorized attributes" do
      let!(:original_price) { room_availability.price }

      before { patch :update, params: { id: room_availability.id, room_availability: { is_available: false, price: 999 } } }

      it "ignores unauthorized price parameter" do
        room_availability.reload
        expect(room_availability.price).to eq(original_price)
      end
    end
  end

  describe "before_action load_room_availability" do
    let!(:room_availability) { room1.room_availabilities.find_by(available_date: Date.today) }

    context "when room availability record exists" do
      it "assigns the record to @room_availability" do
        get :edit, params: { id: room_availability.id }
        expect(assigns(:room_availability)).to eq(room_availability)
      end
    end

    context "when room availability record does not exist" do
      before { get :edit, params: { id: -1 } }

      it "displays not found error message" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_availabilities.load_room_availability.not_found"))
      end

      it "redirects to room availabilities index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end
    end
  end
end
