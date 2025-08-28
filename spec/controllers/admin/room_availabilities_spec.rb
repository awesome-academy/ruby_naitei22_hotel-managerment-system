require "rails_helper"

RSpec.describe Admin::RoomAvailabilitiesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:room_type) { create(:room_type) }
  let!(:room1) { create(:room, room_type: room_type, room_number: "A101", price_from_date: Date.today, price_to_date: Date.today + 10.days, price: 100) }
  let!(:room2) { create(:room, room_type: room_type, room_number: "A102", price_from_date: Date.today, price_to_date: Date.today + 10.days, price: 200) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    context "without params (uses default date range and ordering)" do
      let!(:ra_today_r1) { room1.room_availabilities.find_by(available_date: Date.today) }
      let!(:ra_today_r2) { room2.room_availabilities.find_by(available_date: Date.today) }
      let!(:ra_mid)      { room1.room_availabilities.find_by(available_date: Date.today + 3.days) }
      let!(:ra_outside)  { room1.room_availabilities.find_by(available_date: Date.today + 10.days) }

      before { get :index }

      it "includes only room_availabilities within default date range" do
        dates = assigns(:room_availabilities).map(&:available_date)
        expect(dates).to all(satisfy { |d| d >= Date.today && d <= Date.today + 7 })
      end

      it "excludes room_availabilities outside default date range" do
        expect(assigns(:room_availabilities)).not_to include(ra_outside)
      end

      it "orders by available_date then room_number" do
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

    context "when record exists" do
      before { get :edit, params: { id: room_availability.id } }

      it "assigns the requested room_availability" do
        expect(assigns(:room_availability)).to eq(room_availability)
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end
    end

    context "when record does not exist" do
      before { get :edit, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end

      it "sets not found flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_availabilities.load_room_availability.not_found"))
      end
    end
  end

  describe "PATCH #update" do
    let!(:room_availability) { room1.room_availabilities.find_by(available_date: Date.today) }

    context "with valid params" do
      before { patch :update, params: { id: room_availability.id, room_availability: { is_available: false } } }

      it "updates the record" do
        room_availability.reload
        expect(room_availability.is_available).to be_falsey
      end

      it "sets success flash" do
        expect(flash[:success]).to eq(I18n.t("admin.room_availabilities.update.success"))
      end

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end
    end

    context "with invalid params (is_available nil)" do
      before { patch :update, params: { id: room_availability.id, room_availability: { is_available: nil } } }

      it "does not update the record" do
        room_availability.reload
        expect(room_availability.is_available).to be_truthy
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.room_availabilities.update.failure"))
      end
    end

    context "when record does not exist" do
      before { patch :update, params: { id: -1, room_availability: { is_available: false } } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end

      it "sets not found flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_availabilities.load_room_availability.not_found"))
      end
    end

    context "with unauthorized params (price)" do
      let!(:old_price) { room_availability.price }

      before { patch :update, params: { id: room_availability.id, room_availability: { is_available: false, price: 999 } } }

      it "ignores unauthorized price attribute" do
        room_availability.reload
        expect(room_availability.price).to eq(old_price) # unchanged
      end
    end
  end

  describe "before_action load_room_availability" do
    let!(:room_availability) { room1.room_availabilities.find_by(available_date: Date.today) }

    context "when record exists" do
      it "assigns @room_availability" do
        get :edit, params: { id: room_availability.id }
        expect(assigns(:room_availability)).to eq(room_availability)
      end
    end

    context "when record does not exist" do
      before { get :edit, params: { id: -999 } }

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_availabilities.load_room_availability.not_found"))
      end

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_availabilities_path)
      end
    end
  end
end
