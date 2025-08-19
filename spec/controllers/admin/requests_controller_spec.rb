require "rails_helper"

RSpec.describe Admin::RequestsController, type: :controller do
  let(:admin) { create(:user, role: :admin) }
  let(:user) { create(:user) }
  let(:booking) { create(:booking, user: user) }
  let(:room_type) { create(:room_type) }
  let(:room) { create(:room, room_type: room_type) }
  let!(:request_record) do
    create(:request, booking: booking, room: room,
                     check_in: Date.today,
                     check_out: Date.today + 2.days)
  end

  before { sign_in admin }

  describe "GET #show" do
    context "when request exists" do
      before { get :show, params: { booking_id: booking.id, id: request_record.id } }

      it "assigns @request" do
        expect(assigns(:request)).to eq(request_record)
      end

      it "returns success status" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when request does not exist" do
      before { get :show, params: { booking_id: booking.id, id: 0 } }

      it "redirects to booking page" do
        expect(response).to redirect_to(admin_booking_path(booking.id))
      end

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.requests.not_found_request"))
      end
    end
  end

  describe "PATCH #update" do
    context "with valid status" do
      let(:valid_params) { { status: Request::CHECKED_OUT_STATUS } }

      before do
        patch :update, params: { booking_id: booking.id, id: request_record.id, request: valid_params }
      end

      it "updates the request" do
        expect(request_record.reload.status).to eq(Request::CHECKED_OUT_STATUS)
      end

      it "redirects to request show page" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
      end

      it "sets flash success" do
        expect(flash[:success]).to eq(I18n.t("admin.requests.success"))
      end
    end

    context "with invalid status (checked_out but has guests)" do
      before do
        # tạo guest liên kết với request
        create(:guest, request: request_record)
        patch :update, params: { booking_id: booking.id, id: request_record.id,
                                 request: { status: Request::CHECKED_OUT_STATUS } }
      end

      it "does not update the request status" do
        expect(request_record.reload.status).not_to eq(Request::CHECKED_OUT_STATUS)
      end

      it "renders show template with 422" do
        expect(response).to render_template(:show)
        expect(response.status).to eq(422)
      end

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.requests.validate_check_out"))
      end
    end

    context "with invalid params" do
      before do
        patch :update, params: { booking_id: booking.id, id: request_record.id, request: { status: nil } }
      end

      it "does not update the request" do
        expect(request_record.reload.status).not_to be_nil
      end

      it "renders show template with 422" do
        expect(response).to render_template(:show)
        expect(response.status).to eq(422)
      end

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.requests.failed"))
      end
    end
  end
end
