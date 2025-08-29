require "rails_helper"

RSpec.describe Admin::RequestsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:booking) { create(:booking) }
  let(:room_type) { create(:room_type) }
  let(:room) { create(:room, room_type: room_type) }
  let(:request) { create(:request, booking: booking, room: room) }
  let!(:guest) { create(:guest, request: request) }

  before do
    sign_in admin
  end

  describe "GET #show" do
    context "when request exists" do
      before do
        get :show, params: { booking_id: booking.id, id: request.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @request" do
        expect(assigns(:request)).to eq(request)
      end

      context "preloaded associations" do
        let(:assigned_request) { assigns(:request) }
        
        it "preloads the booking association" do
          expect(assigned_request.booking).to eq(booking)
        end

        it "preloads the guests association" do
          expect(assigned_request.guests).to eq([guest])
        end

        it "preloads the room association" do
          expect(assigned_request.room).to eq(room)
        end

        it "preloads the room type association" do
          expect(assigned_request.room.room_type).to eq(room_type)
        end
      end
    end

    context "when request does not exist" do
      before do
        get :show, params: { booking_id: booking.id, id: -1 }
      end

      it "redirects to admin booking path" do
        expect(response).to redirect_to(admin_booking_path(booking.id))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.requests.not_found_request"))
      end
    end

    context "when request belongs to different booking" do
      let(:other_booking) { create(:booking) }
      let(:other_request) { create(:request, booking: other_booking, room: room) }

      before do
        get :show, params: { booking_id: booking.id, id: other_request.id }
      end

      it "redirects to admin booking path" do
        expect(response).to redirect_to(admin_booking_path(booking.id))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.requests.not_found_request"))
      end
    end
  end

  describe "PATCH #update" do
    let(:valid_params) do
      { booking_id: booking.id, id: request.id, request: { status: "confirmed" } }
    end

    context "with valid parameters" do
      before do
        patch :update, params: valid_params
      end

      it "updates the request" do
        request.reload
        expect(request.status).to eq("confirmed")
      end

      it "redirects to admin booking request path" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request))
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t("admin.requests.update.success"))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { booking_id: booking.id, id: request.id, request: { status: "confirmed", number_of_guests: 6 } }
      end

      before do
        allow_any_instance_of(Request).to receive(:update).and_return(false)
        patch :update, params: invalid_params
      end

      it "does not update the request" do
        original_status = request.status
        request.reload
        expect(request.status).to eq(original_status)
      end

      it "renders show template" do
        expect(response).to render_template(:show)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash message" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.requests.update.failed"))
      end
    end

    context "when checking out without guests" do
      let(:request_without_guests) { create(:request, booking: booking, room: room) }
      let(:checkout_params) do
        { booking_id: booking.id, id: request_without_guests.id, request: { status: "checked_out" } }
      end

      before do
        patch :update, params: checkout_params
      end

      context "prevents checkout behavior" do
        it "renders show template" do
          expect(response).to render_template(:show)
        end

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "sets danger flash message" do
          expect(flash[:danger]).to eq(I18n.t("admin.requests.update.validate_check_out"))
        end
      end

      it "does not update the request status" do
        original_status = request_without_guests.status
        request_without_guests.reload
        expect(request_without_guests.status).to eq(original_status)
      end
    end

    context "when checking out with guests" do
      let(:checkout_params) do
        { booking_id: booking.id, id: request.id, request: { status: "checked_out" } }
      end

      before do
        patch :update, params: checkout_params
      end

      it "allows checkout" do
        request.reload
        expect(request.status).to eq("checked_out")
      end

      it "redirects to admin booking request path" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request))
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t("admin.requests.update.success"))
      end
    end

    context "when request does not exist" do
      before do
        patch :update, params: { booking_id: booking.id, id: -1, request: { status: "confirmed" } }
      end

      it "redirects to admin booking path" do
        expect(response).to redirect_to(admin_booking_path(booking.id))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.requests.not_found_request"))
      end
    end
  end

  describe "authentication and authorization" do
    context "when user is not admin" do
      before do
        sign_out admin
        sign_in regular_user
      end

      context "GET #show" do
        it "redirects due to lack of authorization" do
          get :show, params: { booking_id: booking.id, id: request.id }
          expect(response).to have_http_status(:redirect)
        end

        it "sets danger flash message" do
          get :show, params: { booking_id: booking.id, id: request.id }
          expect(flash[:danger]).to be_present
        end
      end

      context "PATCH #update" do
        it "redirects due to lack of authorization" do
          patch :update, params: { booking_id: booking.id, id: request.id, request: { status: "confirmed" } }
          expect(response).to have_http_status(:redirect)
        end

        it "sets danger flash message" do
          patch :update, params: { booking_id: booking.id, id: request.id, request: { status: "confirmed" } }
          expect(flash[:danger]).to be_present
        end
      end
    end

    context "when user is not signed in" do
      before do
        sign_out admin
      end

      context "GET #show" do
        it "redirects to sign in page" do
          get :show, params: { booking_id: booking.id, id: request.id }
          expect(response).to have_http_status(:redirect)
        end
      end

      context "PATCH #update" do
        it "redirects to sign in page" do
          patch :update, params: { booking_id: booking.id, id: request.id, request: { status: "confirmed" } }
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end

  describe "private methods" do
    describe "#request_params" do
      it "permits only status parameter" do
        controller_params = ActionController::Parameters.new(
          request: { status: "confirmed", unauthorized_param: "value" }
        )
        
        allow(controller).to receive(:params).and_return(controller_params)
        permitted_params = controller.send(:request_params)
        
        expect(permitted_params).to eq({ "status" => "confirmed" })
      end
    end
  end
end
