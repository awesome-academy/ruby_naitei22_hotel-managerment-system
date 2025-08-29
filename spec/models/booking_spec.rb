require "rails_helper"

RSpec.describe Booking, type: :model do
  let!(:user) { create(:user) }
  let!(:admin) { create(:user, :admin) }
  let!(:room_type) { create(:room_type) }
  let!(:room) { create(:room, room_type: room_type) }
  let!(:booking) { create(:booking, user: user) }
  let!(:request) { create(:request, booking: booking, room: room) }
  let!(:room_availability) { room.room_availabilities.first }
  let!(:room_availability_request) { create(:room_availability_request, request: request, room_availability: room_availability) }

  describe "associations" do
    it "belongs to user" do
      expect(booking.user).to eq(user)
    end

    it "belongs to status_changed_by (optional)" do
      booking.status_changed_by = admin
      expect(booking.status_changed_by).to eq(admin)
    end

    it "has many requests" do
      expect(booking.requests).to include(request)
    end

    it "has many room_availability_requests through requests" do
      expect(booking.room_availability_requests).to include(room_availability_request)
    end

    it "has many room_availabilities through room_availability_requests" do
      expect(booking.room_availabilities).to include(room_availability)
    end

    it "has many rooms through room_availabilities" do
      expect(booking.rooms).to include(room)
    end
  end

  describe "nested attributes" do
    it "accepts nested attributes for requests" do
      booking_params = {
        requests_attributes: [
          {
            room_id: room.id,
            check_in: 1.day.from_now,
            check_out: 3.days.from_now,
            number_of_guests: 2
          }
        ]
      }
      
      expect { booking.update(booking_params) }.to change { booking.requests.count }.by(1)
    end
  end

  describe "enums" do
    it "uses status prefix" do
      booking.update(status: :confirmed)
      expect(booking.status_confirmed?).to be true
    end
  end

  describe "callbacks" do
    describe "after_update - cascade_requests_on_confirm" do
      context "when booking is confirmed" do
        let!(:pending_request1) { create(:request, booking: booking, room: room, status: :pending) }
        let!(:pending_request2) { create(:request, booking: booking, room: room, status: :pending) }

        before { booking.update(status: :confirmed) }

        it "updates first pending request to confirmed" do
          expect(pending_request1.reload.status).to eq("confirmed")
        end

        it "updates second pending request to confirmed" do
          expect(pending_request2.reload.status).to eq("confirmed")
        end
      end
    end

    describe "after_update - cascade_requests_on_decline" do
      context "when booking is declined" do
        let!(:pending_request1) { create(:request, booking: booking, room: room, status: :pending) }
        let!(:pending_request2) { create(:request, booking: booking, room: room, status: :pending) }

        before { booking.update(status: :declined) }

        it "updates first pending request to declined" do
          expect(pending_request1.reload.status).to eq("declined")
        end

        it "updates second pending request to declined" do
          expect(pending_request2.reload.status).to eq("declined")
        end
      end
    end
  end

  describe "scopes" do
    describe ".by_booking_id" do
      it "orders bookings by id descending" do
        booking3 = create(:booking, user: user)
        
        result = Booking.by_booking_id
        expect(result.first).to eq(booking3)
      end
    end

    describe ".with_total_guests" do
      it "includes total guests from requests" do
        create(:request, booking: booking, room: room, number_of_guests: 3)
        create(:request, booking: booking, room: room, number_of_guests: 4)
        
        result = Booking.with_total_guests.find(booking.id)
        expect(result.number_of_guests).to eq(9)
      end
    end

    describe ".with_total_price" do
      it "includes total price from room availabilities" do
        room_availability2 = room.room_availabilities.second
        room_availability.update(price: 100)
        room_availability2.update(price: 150)

        create(:room_availability_request, request: request, room_availability: room_availability2)
        
        result = Booking.with_total_price.find(booking.id)
        expect(result.total_price).to eq(250)
      end
    end

    describe ".with_total_requests" do
      it "includes total number of requests" do
        create(:request, booking: booking, room: room)
        create(:request, booking: booking, room: room)
        
        result = Booking.with_total_requests.find(booking.id)
        expect(result.total_requests).to eq(3)
      end
    end
  end

  describe "class methods" do
    describe ".ransackable_attributes" do
      it "returns allowed searchable attributes" do
        expect(Booking.ransackable_attributes).to eq(%w(booking_code status))
      end
    end

    describe ".ransackable_associations" do
      it "returns allowed searchable associations" do
        expect(Booking.ransackable_associations).to eq(%w(user))
      end
    end
  end

  describe "instance methods" do
    describe "#all_requests_checked_out?" do
      it "returns true when all requests are checked out" do
        request.update(status: :checked_out)
        create(:request, booking: booking, room: room, status: :checked_out)
        
        expect(booking.all_requests_checked_out?).to be true
      end

      it "returns false when not all requests are checked out" do
        request.update(status: :checked_out)
        create(:request, booking: booking, room: room, status: :confirmed)
        
        expect(booking.all_requests_checked_out?).to be false
      end
    end

    describe "#send_confirmation_email" do
      context "when sending confirmation email" do
        it "calls BookingMailer.booking_confirmation with booking" do
          expect(BookingMailer).to receive(:booking_confirmation).with(booking).and_call_original
          allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
          
          booking.send_confirmation_email
        end

        it "calls deliver_later on the message delivery" do
          allow(BookingMailer).to receive(:booking_confirmation).with(booking).and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
          
          booking.send_confirmation_email
        end
      end
    end

    describe "#send_decline_email" do
      context "when sending decline email" do
        it "calls BookingMailer.booking_decline with booking" do
          expect(BookingMailer).to receive(:booking_decline).with(booking).and_call_original
          allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
          
          booking.send_decline_email
        end

        it "calls deliver_later on the message delivery" do
          allow(BookingMailer).to receive(:booking_decline).with(booking).and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
          
          booking.send_decline_email
        end
      end
    end
  end

  describe "dependent destroy" do
    it "destroys associated requests when booking is destroyed" do
      request_id = request.id
      booking.destroy
      
      expect { Request.find(request_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
