require "rails_helper"

RSpec.describe Admin::RequestsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:room_type) { create(:room_type) }
  let!(:room) { create(:room, room_type: room_type) }
  let!(:booking) { create(:booking) }
  let!(:request_record) { create(:request, booking: booking, room: room) }

  before do
    sign_in admin
  end

  describe "GET #show" do
    context "when record exists" do
      before { get :show, params: { booking_id: booking.id, id: request_record.id } }

      it "assigns the requested @request" do
        expect(assigns(:request)).to eq(request_record)
      end

      it "renders show template" do
        expect(response).to render_template(:show)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params (change status to checked_in)" do
      before { patch :update, params: { booking_id: booking.id, id: request_record.id, request: { status: :checked_in } } }

      it "updates status" do
        expect(request_record.reload.status).to eq("checked_in")
      end

      it "sets success flash" do
        expect(flash[:success]).to eq(I18n.t("admin.requests.update.success"))
      end

      it "redirects to show" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
      end
    end

    context "when trying to check_out without guests (validate_check_out before_action)" do
      before { patch :update, params: { booking_id: booking.id, id: request_record.id, request: { status: :checked_out } } }

      it "does not change status" do
        expect(request_record.reload.status).to eq("pending")
      end

      it "renders show template" do
        expect(response).to render_template(:show)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash with validation message" do
        expect(flash[:danger]).to eq(I18n.t("admin.requests.update.validate_check_out"))
      end
    end

    context "when checking out with at least one guest" do
      before do
        Guest.create!(
          request: request_record,
          full_name: "John Doe",
          identity_type: :national_id,
          identity_number: "123456789012",
            identity_issued_date: Date.today,
          identity_issued_place: "HN"
        )
        patch :update, params: { booking_id: booking.id, id: request_record.id, request: { status: :checked_out } }
      end

      it "updates status to checked_out" do
        expect(request_record.reload.status).to eq("checked_out")
      end

      it "sets success flash" do
        expect(flash[:success]).to eq(I18n.t("admin.requests.update.success"))
      end

      it "redirects to show page" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
      end
    end
  end
end
