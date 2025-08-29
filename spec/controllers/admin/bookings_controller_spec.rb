require "rails_helper"

RSpec.describe Admin::BookingsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:room) { create(:room) }
  let(:booking1) { create(:booking, user: user) }
  let(:booking2) { create(:booking, user: user) }
  let(:request1) { create(:request, booking: booking1, room: room) }
  let(:request2) { create(:request, booking: booking2, room: room) }
  
  before do
    sign_in admin
    allow(BookingMailer).to receive(:booking_confirmation).and_return(double(deliver_later: true))
    allow(BookingMailer).to receive(:booking_decline).and_return(double(deliver_later: true))
  end

  describe "GET #index" do
    before do
      request1
      request2
      get :index
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns @q for ransack search" do
      expect(assigns(:q)).to be_present
    end

    it "assigns @pagy for pagination" do
      expect(assigns(:pagy)).to be_present
    end

    context "with pagination" do
      let!(:bookings) { create_list(:booking, 15, user: user) }  

      let(:pagy) { assigns(:pagy) }
      
      before do
        bookings.each do |booking|
          request = create(:request, booking: booking, room: room)
          (request.check_in.to_date..request.check_out.to_date).each do |date|
            room_availability = room.room_availabilities.find_by(available_date: date)
            if room_availability
              create(:room_availability_request, request: request, room_availability: room_availability)
            end
          end
        end

        get :index
      end

      it "assigns @pagy" do
        expect(pagy).to be_present
      end

      it "has 10 items per page" do
        expect(pagy.vars[:items]).to eq(Settings.default.digit_10)
      end

      it "calculates correct total pages" do
        expect(pagy.pages).to eq(2)
      end
    end

    context "ransack search" do
      it "applies search parameters" do
        get :index, params: { q: { booking_code_cont: "test" } }
        expect(assigns(:q).booking_code_cont).to eq("test")
      end
    end
  end

  describe "GET #show action" do
    context "when booking exists" do
      before do
        request1
        allow(controller).to receive(:load_booking_by_id) do
          controller.instance_variable_set(:@booking, booking1)
          controller.instance_variable_set(:@bookings, Booking.all)
        end
        get :show, params: { id: booking1.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @booking" do
        expect(assigns(:booking)).to eq(booking1)
      end
    end

    context "when booking does not exist" do
      before do
        get :show, params: { id: -1 }
      end

      it "redirects to admin bookings index" do
        expect(response).to redirect_to(admin_bookings_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.bookings.not_found"))
      end
    end
  end

  describe "PATCH #update_status" do
    let(:booking) { create(:booking, user: user) }
    
    before do
      create(:request, booking: booking, room: room)
    end

    context "with valid parameters" do
      before do
        allow(controller).to receive(:load_booking_by_id) do
          controller.instance_variable_set(:@booking, booking)
          controller.instance_variable_set(:@bookings, Booking.all)
        end
        patch :update_status, params: { id: booking.id, booking: { status: "confirmed" } }
      end

      it "updates the booking status" do
        booking.reload
        expect(booking.status).to eq("confirmed")
      end

      it "sets status_changed_by to current user" do
        booking.reload
        expect(booking.status_changed_by).to eq(admin)
      end

      it "redirects to booking show page" do
        expect(response).to redirect_to(admin_booking_path(booking))
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t("admin.bookings.update_status.success"))
      end

      context "when status is confirmed" do
        it "sends confirmation email" do
          expect(BookingMailer).to have_received(:booking_confirmation)
        end
      end
    end

    context "with transaction error" do
      before do
        allow(controller).to receive(:load_booking_by_id) do
          controller.instance_variable_set(:@booking, booking)
          controller.instance_variable_set(:@bookings, Booking.all)
        end
        
        allow(booking).to receive(:lock!)
        allow(booking).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(booking))
        allow(booking.errors).to receive(:full_messages).and_return(["Invalid status"])
        allow(booking.errors).to receive_message_chain(:full_messages, :to_sentence).and_return("Invalid status")
        
        patch :update_status, params: { id: booking.id, booking: { status: "" } }
      end

      it "renders show template" do
        expect(response).to render_template(:show)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash message" do
        expect(flash.now[:danger]).to eq("Invalid status")
      end
    end

    context "when booking does not exist" do
      before do
        patch :update_status, params: { id: -1, booking: { status: "confirmed" } }
      end

      it "redirects to admin bookings index" do
        expect(response).to redirect_to(admin_bookings_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.bookings.not_found"))
      end
    end
  end

  describe "GET #show_decline" do
    context "when booking exists" do
      let(:booking) { create(:booking, user: user) }
      
      before do
        create(:request, booking: booking, room: room)
        allow(controller).to receive(:load_booking_by_id) do
          controller.instance_variable_set(:@booking, booking)
          controller.instance_variable_set(:@bookings, Booking.all)
        end
        get :show_decline, params: { id: booking.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders show_decline template" do
        expect(response).to render_template(:show_decline)
      end

      it "renders template without layout" do
        expect(response).to render_template(layout: false)
      end

      it "assigns @booking" do
        expect(assigns(:booking)).to eq(booking)
      end
    end

    context "when booking does not exist" do
      before do
        get :show_decline, params: { id: -1 }
      end

      it "redirects to admin bookings index" do
        expect(response).to redirect_to(admin_bookings_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.bookings.not_found"))
      end
    end
  end

  describe "PATCH #decline" do
    let(:booking) { create(:booking, user: user) }
    
    before do
      create(:request, booking: booking, room: room)
    end

    context "with valid parameters" do
      before do
        allow(controller).to receive(:load_booking_by_id) do
          controller.instance_variable_set(:@booking, booking)
          controller.instance_variable_set(:@bookings, Booking.all)
        end
        patch :decline, params: { id: booking.id, booking: { status: "declined", decline_reason: "No rooms available" } }
      end

      it "updates the booking status to declined" do
        booking.reload
        expect(booking.status).to eq("declined")
      end

      it "sets decline reason" do
        booking.reload
        expect(booking.decline_reason).to eq("No rooms available")
      end

      it "sets status_changed_by to current user" do
        booking.reload
        expect(booking.status_changed_by).to eq(admin)
      end

      it "redirects to booking show page" do
        expect(response).to redirect_to(admin_booking_path(booking))
      end

      it "returns see_other status" do
        expect(response).to have_http_status(:see_other)
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t("admin.bookings.decline.success"))
      end

      context "when status is declined" do
        it "sends decline email" do
          expect(BookingMailer).to have_received(:booking_decline)
        end
      end
    end

    context "with transaction error" do
      before do
        allow(controller).to receive(:load_booking_by_id) do
          controller.instance_variable_set(:@booking, booking)
          controller.instance_variable_set(:@bookings, Booking.all)
        end
        
        allow(booking).to receive(:lock!)
        allow(booking).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(booking))
        allow(booking.errors).to receive_message_chain(:full_messages, :to_sentence).and_return("Decline reason required")
        
        allow(controller).to receive(:render) do |*args|
          controller.response.status = 422
          controller.response.body = ""
        end
        
        patch :decline, params: { id: booking.id, booking: { status: "declined", decline_reason: "" } }
      end

      it "calls render with decline template and no layout" do
        expect(controller).to have_received(:render).with(:decline, layout: false, status: :unprocessable_entity)
      end

      it "sets danger flash message" do
        expect(flash.now[:danger]).to eq("Decline reason required")
      end
    end

    context "when booking does not exist" do
      before do
        patch :decline, params: { id: -1, booking: { status: "declined", decline_reason: "Test" } }
      end

      it "redirects to admin bookings index" do
        expect(response).to redirect_to(admin_bookings_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.bookings.not_found"))
      end
    end
  end

  describe "private methods" do
    describe "#booking_params" do
      let(:controller_params) do
        ActionController::Parameters.new(
          booking: { status: "confirmed", decline_reason: "test", unauthorized_param: "value" }
        )
      end
      
      before do
        allow(controller).to receive(:params).and_return(controller_params)
      end

      it "permits only allowed parameters" do
        permitted_params = controller.send(:booking_params)
        expect(permitted_params.keys).to contain_exactly("status", "decline_reason")
      end

      it "does not include unauthorized parameters" do
        permitted_params = controller.send(:booking_params)
        expect(permitted_params.keys).not_to include("unauthorized_param")
      end
    end
  end
end
