require "rails_helper"

RSpec.describe Admin::GuestsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:user) { create(:user) }
  let(:room) { create(:room) }
  let(:booking) { create(:booking, user: user) }
  let(:request_obj) { create(:request, :checked_in, booking: booking, room: room) }
  let(:guest) { create(:guest, request: request_obj) }

  before do
    sign_in admin
  end

  describe "GET #new" do
    context "when request exists and is checked in" do
      before do
        get :new, params: { booking_id: booking.id, request_id: request_obj.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @request" do
        expect(assigns(:request)).to eq(request_obj)
      end

      it "assigns @booking" do
        expect(assigns(:booking)).to eq(booking)
      end

      it "builds new guest" do
        expect(assigns(:guest).request).to eq(request_obj)
      end
    end

    context "when request does not exist" do
      before do
        get :new, params: { booking_id: booking.id, request_id: -1 }
      end

      it "redirects to admin bookings index" do
        expect(response).to redirect_to(admin_bookings_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.new.request_not_found"))
      end
    end

    context "when request is not checked in" do
      let(:pending_request) { create(:request, booking: booking, room: room) }

      before do
        get :new, params: { booking_id: booking.id, request_id: pending_request.id }
      end

      it "redirects to request show page" do
        expect(response).to redirect_to(admin_booking_request_path(booking.id, pending_request))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.request_not_checked_in"))
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        full_name: "Nguyen Van A",
        identity_type: "national_id",
        identity_number: "123456789012",
        identity_issued_date: 2.years.ago.to_date,
        identity_issued_place: "Ha Noi"
      }
    end

    let(:invalid_attributes) do
      {
        full_name: "",
        identity_type: "",
        identity_number: "",
        identity_issued_date: nil,
        identity_issued_place: ""
      }
    end

    context "with valid parameters" do
      before do
        post :create, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id,
          guest: valid_attributes 
        }
      end

      it "creates a new guest" do
        expect(Guest.last.full_name).to eq("Nguyen Van A")
      end

      it "redirects to request show page" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request_obj))
      end

      it "returns see_other status" do
        expect(response).to have_http_status(:see_other)
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t("admin.guests.create.success"))
      end

      it "assigns guest to request" do
        guest = Guest.last
        expect(guest.request).to eq(request_obj)
      end
    end

    context "with invalid parameters" do
      before do
        post :create, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id,
          guest: invalid_attributes 
        }
      end

      it "does not create a new guest" do
        expect(Guest.count).to eq(0)
      end

      it "renders new template" do
        expect(response).to render_template(:new)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns @guest with errors" do
        expect(assigns(:guest).errors).to be_present
      end
    end
  end

  describe "GET #edit" do
    context "when guest exist" do
      before do
        get :edit, params: { booking_id: booking.id, request_id: request_obj.id, id: guest.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @guest" do
        expect(assigns(:guest)).to eq(guest)
      end

      it "assigns @request" do
        expect(assigns(:request)).to eq(request_obj)
      end

      it "assigns @booking" do
        expect(assigns(:booking)).to eq(booking)
      end
    end

    context "when guest does not exist" do
      before do
        get :edit, params: { booking_id: booking.id, request_id: request_obj.id, id: -1 }
      end

      it "redirects to request show page" do
        expect(response).to redirect_to(admin_booking_request_path(booking.id, request_obj))
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.guest_not_found"))
      end
    end
  end

  describe "PATCH #update" do
    let(:new_attributes) do
      {
        full_name: "Jane Doe Updated",
        identity_type: "passport",
        identity_number: "a1234567",
        identity_issued_date: 1.year.ago.to_date,
        identity_issued_place: "Ho Chi Minh"
      }
    end

    let(:invalid_attributes) do
      {
        full_name: "",
        identity_type: "",
        identity_number: "",
        identity_issued_date: nil,
        identity_issued_place: ""
      }
    end

    context "with valid parameters" do
      before do
        patch :update, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id, 
          id: guest.id,
          guest: new_attributes 
        }
      end

      it "updates the guest" do
        guest.reload
        expect(guest.full_name).to eq("Jane Doe Updated")
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns see_other status" do
        expect(response).to have_http_status(:see_other)
      end

      it "sets success flash message" do
        expect(flash.now[:success]).to eq(I18n.t("admin.guests.update.success"))
      end
    end

    context "with invalid parameters" do
      before do
        patch :update, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id, 
          id: guest.id,
          guest: invalid_attributes 
        }
      end

      it "does not update the guest" do
        guest.reload
        expect(guest.full_name).not_to eq("")
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "assigns @guest with errors" do
        expect(assigns(:guest).errors).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    
    before do
      guest 
      delete :destroy, params: { booking_id: booking.id, request_id: request_obj.id, id: guest.id }
    end
    context "when guest exists" do
      it "destroys the guest" do
        expect(Guest.find_by(id: guest.id)).to be_nil
      end

      it "redirects to request show page" do
        expect(response).to redirect_to(admin_booking_request_path(booking, request_obj))
      end

      it "returns see_other status" do
        expect(response).to have_http_status(:see_other)
      end

      it "sets success flash message" do
        expect(flash[:success]).to be_present
      end
    end

    context "when guest destroy fails" do
      let(:mock_guest) { instance_double(Guest, id: 999, request: request_obj) }
      
      before do
        allow(Guest).to receive(:find_by).with(id: mock_guest.id.to_s).and_return(mock_guest)
        allow(mock_guest).to receive(:destroy).and_return(false)
        delete :destroy, params: { booking_id: booking.id, request_id: request_obj.id, id: mock_guest.id }
      end

      it "calls destroy on guest" do
        expect(mock_guest).to have_received(:destroy)
      end

      it "redirects to request show page" do
        expect(response.body).to include(admin_booking_request_path(booking, request_obj))
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.guests.destroy.error"))
      end
    end

  end

  describe "authentication and authorization" do
    context "when user is not admin" do
      before { sign_in regular_user }

      it "GET #new redirects due to lack of authorization" do
        get :new, params: { booking_id: booking.id, request_id: request_obj.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to be_present
      end

      it "POST #create redirects due to lack of authorization" do
        post :create, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id, 
          guest: { full_name: "Test" } 
        }
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to be_present
      end

      it "GET #edit redirects due to lack of authorization" do
        get :edit, params: { booking_id: booking.id, request_id: request_obj.id, id: guest.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to be_present
      end

      it "PATCH #update redirects due to lack of authorization" do
        patch :update, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id, 
          id: guest.id, 
          guest: { full_name: "Updated" } 
        }
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to be_present
      end

      it "DELETE #destroy redirects due to lack of authorization" do
        delete :destroy, params: { booking_id: booking.id, request_id: request_obj.id, id: guest.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to be_present
      end
    end

    context "when user is not signed in" do
      before { sign_out admin }

      it "GET #new redirects to sign in page" do
        get :new, params: { booking_id: booking.id, request_id: request_obj.id }
        expect(response).to redirect_to(root_path)
      end

      it "POST #create redirects to sign in page" do
        post :create, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id, 
          guest: { full_name: "Test" } 
        }
        expect(response).to redirect_to(root_path)
      end

      it "GET #edit redirects to sign in page" do
        get :edit, params: { booking_id: booking.id, request_id: request_obj.id, id: guest.id }
        expect(response).to redirect_to(root_path)
      end

      it "PATCH #update redirects to sign in page" do
        patch :update, params: { 
          booking_id: booking.id, 
          request_id: request_obj.id, 
          id: guest.id, 
          guest: { full_name: "Updated" } 
        }
        expect(response).to redirect_to(root_path)
      end

      it "DELETE #destroy redirects to sign in page" do
        delete :destroy, params: { booking_id: booking.id, request_id: request_obj.id, id: guest.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "private methods" do
    describe "#guest_params" do
      before { sign_in admin }

      it "permits only allowed parameters" do
        params = ActionController::Parameters.new(
          guest: {
            full_name: "John Doe",
            identity_type: "national_id",
            identity_number: "123456789012",
            identity_issued_date: Date.current,
            identity_issued_place: "Ha Noi",
            images: [],
            unauthorized_param: "should not be permitted"
          }
        )
        
        controller.params = params
        permitted = controller.send(:guest_params)
        
        expect(permitted.keys).not_to include("unauthorized_param")
      end

      it "does not include unauthorized parameters" do
        params = ActionController::Parameters.new(
          guest: {
            full_name: "John Doe",
            admin: true,
            role: "admin"
          }
        )
        
        controller.params = params
        permitted = controller.send(:guest_params)
        
        expect(permitted.keys).not_to include("admin", "role")
      end
    end
  end
end
