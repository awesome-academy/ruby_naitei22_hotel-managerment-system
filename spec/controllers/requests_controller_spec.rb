require "rails_helper"

RSpec.describe RequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:booking) { create(:booking, user: user) }
  let(:request_record) { create(:request, status: :pending) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "DELETE #destroy" do
    context "when request exists" do
      before { request_record } # ensure created

      it "destroys the request" do
        expect {
          delete :destroy, params: { id: request_record.id }
        }.to change(Request, :count).by(-1)
      end

      it "sets flash[:success]" do
        delete :destroy, params: { id: request_record.id }
        expect(flash[:success]).to be_present
      end

      it "redirects to current_booking_bookings_path" do
        delete :destroy, params: { id: request_record.id }
        expect(response).to redirect_to(current_booking_bookings_path)
      end

      it "fails to destroy the request and sets flash[:success]" do
        allow_any_instance_of(Request).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: request_record.id }

        expect(flash[:danger]).to be_present
      end

      it "fails to destroy the request and redirects to current_booking_bookings_path" do
        allow_any_instance_of(Request).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: request_record.id }

        expect(response).to redirect_to(current_booking_bookings_path)
      end
    end

    context "when request not found" do
      before { delete :destroy, params: { id: -1 } }

      it "sets flash[:warning]" do
        expect(flash[:warning]).to be_present
      end

      it "redirects to root_path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PUT #cancel" do
    context "when update succeeds" do
      before { put :cancel, params: { id: request_record.id, user_id: user.id } }

      it "sets status to cancelled" do
        expect(request_record.reload.status).to eq("cancelled")
      end

      it "sets flash[:success]" do
        expect(flash[:success]).to be_present
      end

      it "redirects to user_bookings_path" do
        expect(response).to redirect_to(user_bookings_path(user))
      end
    end

    context "when update fails" do
      before do
        allow_any_instance_of(Request).to receive(:update).and_return(false)
        put :cancel, params: { id: request_record.id, user_id: user.id }
      end

      it "sets flash[:error]" do
        expect(flash[:error]).to be_present
      end

      it "redirects to user_bookings_path" do
        expect(response).to redirect_to(user_bookings_path(user))
      end
    end

    context "when request status is not pending" do
      let(:non_pending_request) { create(:request, status: :confirmed, booking: booking) }
      before { put :cancel, params: { id: non_pending_request.id, user_id: user.id } }

      it "sets flash[:alert]" do
        expect(flash[:alert]).to be_present
      end

      it "redirects to user_bookings_path" do
        expect(response).to redirect_to(user_bookings_path(user))
      end
    end
  end
end
