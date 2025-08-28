require "rails_helper"

RSpec.describe Admin::GuestsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:room) { create(:room) }
  let!(:booking) { create(:booking) }
  let!(:request_record) { create(:request, booking: booking, room: room, status: :checked_in) }

  before do
    sign_in admin
  end

  describe "GET #new" do
    context "when request is checked_in" do
      before { get :new, params: { booking_id: booking.id, request_id: request_record.id } }

      it "assigns a new guest" do
        expect(assigns(:guest)).to be_a_new(Guest)
      end

      it "renders new template" do
        expect(response).to render_template(:new)
      end
    end

    context "when request not found" do
      before { get :new, params: { booking_id: booking.id, request_id: -1 } }

      it "redirects to bookings index" do
        expect(response).to redirect_to(admin_bookings_path)
      end

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.new.request_not_found"))
      end
    end

    context "when request not checked_in" do
      let!(:not_checked_request) { create(:request, booking: booking, room: room, status: :pending) }
      before { get :new, params: { booking_id: booking.id, request_id: not_checked_request.id } }

      it "redirects to request show" do
        expect(response).to redirect_to(admin_booking_request_path(booking, not_checked_request))
      end

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.request_not_checked_in"))
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        full_name: "John Doe",
        identity_type: :national_id,
        identity_number: "123456789012",
        identity_issued_date: Date.today - 1.day,
        identity_issued_place: "HN"
      }
    end

    context "with valid params" do
      it "creates a guest" do
        expect do
          post :create, params: { booking_id: booking.id, request_id: request_record.id, guest: valid_params }
        end.to change(Guest, :count).by(1)
      end

      context "after create request" do
        before do
          post :create, params: { booking_id: booking.id, request_id: request_record.id, guest: valid_params }
        end

        it "redirects to request show" do
          expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
        end

        it "sets success flash" do
          expect(flash[:success]).to eq(I18n.t("admin.guests.create.success"))
        end
      end
    end

    context "with invalid params" do
      it "does not create guest" do
        expect do
          post :create, params: { booking_id: booking.id, request_id: request_record.id, guest: valid_params.merge(full_name: "") }
        end.not_to change(Guest, :count)
      end

      context "after invalid create request" do
        before do
          post :create, params: { booking_id: booking.id, request_id: request_record.id, guest: valid_params.merge(full_name: "") }
        end

        it "renders new" do
          expect(response).to render_template(:new)
        end

        it "returns unprocessable status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when request not checked_in" do
      let!(:not_checked_request) { create(:request, booking: booking, room: room, status: :pending) }
      it "does not create guest" do
        expect do
          post :create, params: { booking_id: booking.id, request_id: not_checked_request.id, guest: valid_params }
        end.not_to change(Guest, :count)
      end

      context "after invalid request status create" do
        before do
          post :create, params: { booking_id: booking.id, request_id: not_checked_request.id, guest: valid_params }
        end

        it "redirects to request show" do
          expect(response).to redirect_to(admin_booking_request_path(booking, not_checked_request))
        end

        it "sets danger flash" do
          expect(flash[:danger]).to eq(I18n.t("admin.guests.request_not_checked_in"))
        end
      end
    end
  end

  describe "GET #edit" do
    let!(:guest) { create(:guest, request: request_record) }

    context "when guest exists" do
      before { get :edit, params: { booking_id: booking.id, request_id: request_record.id, id: guest.id } }

      it "assigns guest" do
        expect(assigns(:guest)).to eq(guest)
      end

      it "renders edit" do
        expect(response).to render_template(:edit)
      end
    end

    context "when guest not found" do
      before { get :edit, params: { booking_id: booking.id, request_id: request_record.id, id: -1 } }

      it "redirects to request show" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
      end

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.edit.guest_not_found"))
      end
    end

    context "when request not checked_in" do
      let!(:not_checked_request) { create(:request, booking: booking, room: room, status: :pending) }
      let!(:guest_pending) { create(:guest, request: not_checked_request) }
      before { get :edit, params: { booking_id: booking.id, request_id: not_checked_request.id, id: guest_pending.id } }

      it "redirects" do
        expect(response).to redirect_to(admin_booking_request_path(booking, not_checked_request))
      end

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.request_not_checked_in"))
      end
    end
  end

  describe "PATCH #update" do
    let!(:guest) { create(:guest, request: request_record, full_name: "Old Name") }

    context "with valid params" do
      before do
        patch :update, params: { booking_id: booking.id, request_id: request_record.id, id: guest.id, guest: { full_name: "New Name" } }
      end

      it "updates guest" do
        expect(guest.reload.full_name).to eq("New Name")
      end

      it "returns see_other status" do
        expect(response).to have_http_status(:see_other)
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end

      it "sets success flash now" do
        expect(flash.now[:success]).to eq(I18n.t("admin.guests.update.success"))
      end
    end

    context "with invalid params" do
      before do
        patch :update, params: { booking_id: booking.id, request_id: request_record.id, id: guest.id, guest: { full_name: "" } }
      end

      it "does not update guest" do
        expect(guest.reload.full_name).to eq("Old Name")
      end

      it "renders edit" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when guest not found" do
      before do
        patch :update, params: { booking_id: booking.id, request_id: request_record.id, id: -1, guest: { full_name: "New" } }
      end

      it "redirects to request show" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
      end
    end

    context "when request not checked_in" do
      let!(:not_checked_request) { create(:request, booking: booking, room: room, status: :pending) }
      let!(:guest_pending) { create(:guest, request: not_checked_request) }
      before do
        patch :update, params: { booking_id: booking.id, request_id: not_checked_request.id, id: guest_pending.id, guest: { full_name: "New" } }
      end

      it "redirects to request show" do
        expect(response).to redirect_to(admin_booking_request_path(booking, not_checked_request))
      end

      it "sets danger flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.request_not_checked_in"))
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:guest) { create(:guest, request: request_record) }

    context "when destroy succeeds" do
      it "deletes guest" do
        expect do
          delete :destroy, params: { booking_id: booking.id, request_id: request_record.id, id: guest.id }
        end.to change(Guest, :count).by(-1)
      end

      context "after destroy request" do
        before do
          delete :destroy, params: { booking_id: booking.id, request_id: request_record.id, id: guest.id }
        end

        it "redirects to request show" do
          expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
        end

        it "sets success flash" do
          expect(flash[:success]).to eq(I18n.t("admin.guests.destroy.success"))
        end
      end
    end

    context "when guest not found" do
      it "redirects to admin bookings" do
        delete :destroy, params: { booking_id: booking.id, request_id: request_record.id, id: -1 }
        expect(response).to redirect_to(admin_booking_request_path(booking, request_record))
      end
    end

    context "when request not checked_in" do
      let!(:not_checked_request) { create(:request, booking: booking, room: room, status: :pending) }
      let!(:guest_pending) { create(:guest, request: not_checked_request) }
      it "does not delete guest" do
        expect do
          delete :destroy, params: { booking_id: booking.id, request_id: not_checked_request.id, id: guest_pending.id }
        end.not_to change(Guest, :count)
      end

      context "after destroy request with invalid status" do
        before do
          delete :destroy, params: { booking_id: booking.id, request_id: not_checked_request.id, id: guest_pending.id }
        end

        it "redirects to request show" do
          expect(response).to redirect_to(admin_booking_request_path(booking, not_checked_request))
        end

        it "sets danger flash" do
          expect(flash[:danger]).to eq(I18n.t("admin.guests.request_not_checked_in"))
        end
      end
    end
  end
end
