require "rails_helper"

RSpec.describe BookingsController, type: :controller do
  let(:user) { create(:user) }
  let(:room_type) { create(:room_type) }
  let(:room) { create(:room, room_type: room_type) }
  let(:booking) { create(:booking, user: user, status: :draft) }
  let!(:request_record) do
    create(:request, booking: booking, room: room,
                     check_in: Date.today,
                     check_out: Date.today + 2.days)
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    context "when logged in" do
      before {get :index}
      it "assigns @bookings" do
        expect(assigns(:bookings)).to eq(user.bookings)
      end

      it "renders index" do
        expect(response).to render_template(:index)
      end
    end

    context "when not logged in" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :index
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to eq I18n.t("bookings.card.need_login")
      end

      it "redirects to root_path if no referer" do
        expect(response).to redirect_to(root_path)
      end

      it "redirects back if referer present" do
        request.env["HTTP_REFERER"] = "/previous_page"
        get :index
        expect(response).to redirect_to("/previous_page")
      end
    end

    context "when current_user has no bookings" do
      let(:this_user) { create(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(this_user)
        get :index
      end

      it "sets flash[:warning]" do
        expect(flash[:warning]).to eq I18n.t("bookings.not_found")
      end

      it "redirects to bookings_path" do
        expect(response).to redirect_to(bookings_path)
      end
    end
  end

  describe "PATCH #update" do
    let(:params) do
      {
        id: booking.id,
        room_id: room.id,
        booking: {
          requests_attributes: [{
            id: request_record.id,
            room_id: room.id,
            check_in: Date.today,
            check_out: Date.today + 1.day,
            number_of_guests: 2,
            note: "Test update"
          }]
        }
      }
    end

    context "update success" do
      it "sets flash[:success]" do
        patch :update, params: params
        expect(flash[:success]).to be_present
      end

      it "redirects to current booking" do
        patch :update, params: params
        expect(response).to redirect_to(current_booking_bookings_path)
      end

      it "creates room availability requests" do
        create(:room_availability, room: room, available_date: Date.today)
        create(:room_availability, room: room, available_date: Date.today + 1.day)

        expect {
          patch :update, params: params
          booking.reload
        }.to change { booking.requests.last.room_availability_requests.count }.by(2)
      end
    end

    context "update failure" do
      before do
        allow_any_instance_of(Booking).to receive(:update!).and_raise(StandardError.new("Update failed"))

        request.env["HTTP_REFERER"] = bookings_path
        patch :update, params: { id: booking.id, room_id: room.id, booking: { requests_attributes: [] } }
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to be_present
      end

      it "redirects back" do
        expect(response).to redirect_to(bookings_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "destroy success" do
      before{delete :destroy, params: { id: booking.id }}

      it "sets flash[:success]" do
        expect(flash[:success]).to be_present
      end

      it "redirects to current booking" do
        expect(response).to redirect_to(current_booking_bookings_path)
      end
    end

    context "destroy failure" do
      before do
        allow_any_instance_of(Booking).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: booking.id }
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to current booking" do
        expect(response).to redirect_to(current_booking_bookings_path)
      end
    end

    context "when booking not found" do
      before{delete :destroy, params: { id: -1 }}
      it "sets flash[:warning]" do
        expect(flash[:warning]).to eq I18n.t("bookings.not_found")
      end

      it "redirects to root_path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #current_booking" do
    context "when booking found" do
      let!(:booking) { create(:booking, user: user) }

      it "renders current_booking template" do
        get :current_booking, params: { id: booking.id }
        expect(response).to render_template(:current_booking)
      end
    end

    context "when booking not found" do
      before{get :current_booking, params: { id: -1 }}

      it "sets flash[:warning]" do
        expect(flash[:warning]).to eq I18n.t("bookings.not_found")
      end

      it "redirects to bookings_path" do
        expect(response).to redirect_to(bookings_path)
      end
    end
  end

  describe "PATCH #confirm_booking" do
    context "when no overlap" do
      before {patch :confirm_booking, params: { id: booking.id }}
      it "confirms booking and sets status pending" do
        booking.reload
        expect(booking.status).to eq("pending")
      end

      it "sets flash[:success]" do
        expect(flash[:success]).to be_present
      end

      it "redirects to bookings_path" do
        expect(response).to redirect_to(bookings_path)
      end
    end

    context "when overlap exists" do
      before do
        other_booking = create(:booking, user: user, status: :confirmed)
        create(:request,
              booking: other_booking,
              room: room,
              status: :confirmed,
              check_in: Date.today,
              check_out: Date.today + 3.days)
        patch :confirm_booking, params: { id: booking.id }
      end

      it "sets flash[:warning] with room number" do
        expect(flash[:warning]).to include(room.room_number)
      end

      it "redirects to current_booking" do
        expect(response).to redirect_to(assigns(:current_booking))
      end
    end

    context "when assign_booking_code_and_status failure" do
      before do
        allow_any_instance_of(Booking).to receive(:update!)
        .and_raise(StandardError.new("Boom error"))

        patch :confirm_booking, params: { id: booking.id }
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to eq("Boom error")
      end

      it "redirects to bookings_path" do
        expect(response).to redirect_to(bookings_path)
      end
    end
  end

  describe "POST #cancel" do
    context "when booking found" do
      it "cancels draft booking" do
        post :cancel, params: { user_id: user.id, id: booking.id }
        booking.reload
        expect(booking.status).to eq("cancelled")
      end

      it "does not cancel confirmed booking" do
        confirmed_booking = create(:booking, user: user, status: :confirmed)
        post :cancel, params: { user_id: user.id, id: confirmed_booking.id }
        expect(flash[:alert]).to be_present
      end
    end

    context "when cancelling booking raises error" do
      before do
        allow_any_instance_of(Booking).to receive(:update!).and_raise(StandardError, "Something went wrong")
        post :cancel, params: { user_id: user.id, id: booking.id }
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to eq "Something went wrong"
      end
    end
  end

  describe "before_action :set_user" do
    context "when user not found" do
      before do 
        allow(controller).to receive(:current_user).and_return(nil)
        get :index, params: { user_id: 9999 }
      end
      
      it "redirects to root_path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "before_action :set_booking" do
    context "when booking not found" do
      before {post :cancel, params: { user_id: user.id, id: 9999 } }

      it "sets flash[:warning]" do
        expect(flash[:warning]).to eq I18n.t("bookings.not_found")
      end

      it "redirects to user_bookings_path" do
        expect(response).to redirect_to(user_bookings_path(user))
      end
    end
  end
end
