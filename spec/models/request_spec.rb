require "rails_helper"

RSpec.describe Request, type: :model do
  let!(:room_type) { create(:room_type) }
  let!(:room) { create(:room, room_type: room_type) }
  let!(:user) { create(:user) }
  let!(:booking) { create(:booking, user: user) }
  let!(:room_availability) { room.room_availabilities.first }
  let!(:request) { create(:request, booking: booking, room: room) }
  let!(:room_availability_request) { create(:room_availability_request, request: request, room_availability: room_availability) }
  describe "associations" do
    context "access through associations" do
      it "can access booking" do
        expect(request.booking).to eq(booking)
      end

      it "can access room" do
        expect(request.room).to eq(room)
      end

      it "can access reviews" do
        review = create(:review, request: request, user: user)
        expect(request.reviews).to include(review)
      end

      it "can access guests" do
        guest = create(:guest, request: request)
        expect(request.guests).to include(guest)
      end

      it "can access room_availability_requests" do
        expect(request.room_availability_requests).to include(room_availability_request)
      end

      it "can access room_availabilities" do
    
        expect(request.room_availabilities).to include(room_availability)
      end
    end
  end

  describe "validations" do
    context "presence validations" do
      it "validates presence of check_in" do
        request.check_in = nil
        request.valid?
        expect(request.errors.of_kind?(:check_in, :blank)).to be true
      end

      it "validates presence of check_out" do
        request.check_out = nil
        request.valid?
        expect(request.errors.of_kind?(:check_out, :blank)).to be true
      end
    end

    context "custom validations" do
      it "validates check_in is before check_out" do
        request.check_in = 2.days.from_now
        request.check_out = 1.day.from_now
        request.valid?
        expect(request.errors.of_kind?(:check_out, :check_in_before_check_out)).to be true
      end

      it "validates check_in is in the future" do
        request.check_in = 1.day.ago
        request.valid?
        expect(request.errors.of_kind?(:check_in, :future)).to be true
      end

      it "allows check_in to be today" do
        request.check_in = Time.zone.today
        request.check_out = 1.day.from_now
        expect(request).to be_valid
      end

      it "allows check_in to be in the future" do
        request.check_in = 1.day.from_now
        request.check_out = 2.days.from_now
        expect(request).to be_valid
      end
    end
  end


  describe "callbacks" do
    describe "after_initialize" do
      it "sets default status to draft for new records" do
        new_request = Request.new
        expect(new_request.status).to eq("draft")
      end

      it "does not set default status for existing records" do
        existing_request = create(:request, status: :confirmed)
        existing_request.reload
        expect(existing_request.status).to eq("confirmed")
      end
    end

    describe "after_update" do
      context "when status is in UNAVAILABLE_STATUSES" do
        it "updates room_availability is_available to false for pending status" do
          request.update(status: :pending)
          expect(room_availability.reload.is_available).to be false
        end

        it "updates room_availability is_available to false for confirmed status" do 
          request.update(status: :confirmed)          
          expect(room_availability.reload.is_available).to be false
        end

        it "updates room_availability is_available to false for checked_in status" do
          request.update(status: :checked_in)
          expect(room_availability.reload.is_available).to be false
        end

        it "updates room_availability is_available to false for checked_out status" do
          request.update(status: :checked_out)
          expect(room_availability.reload.is_available).to be false
        end
      end

      context "when status is not in UNAVAILABLE_STATUSES" do
        it "updates room_availability is_available to true for draft status" do
          room_availability.update(is_available: false)
          request.update(status: :draft)
          expect(room_availability.reload.is_available).to be true
        end

        it "updates room_availability is_available to true for declined status" do
          room_availability.update(is_available: false)
          request.update(status: :declined)
          expect(room_availability.reload.is_available).to be true
        end

        it "updates room_availability is_available to true for cancelled status" do
          room_availability.update(is_available: false)
          request.update(status: :cancelled)
          expect(room_availability.reload.is_available).to be true
        end
      end
    end
  end

  describe "instance methods" do
    describe "#calculate_price" do
      context "when check_in and check_out are present" do
        it "calculates total price for date range" do
          availabilities = room.room_availabilities.limit(3)
          
          availabilities[0].update!(price: 100)
          availabilities[1].update!(price: 120) 
          availabilities[2].update!(price: 110)
          
          request.check_in = availabilities[0].available_date
          request.check_out = availabilities[2].available_date
          
          expected_price = availabilities[0].price + availabilities[1].price + availabilities[2].price
          expect(request.calculate_price).to eq(expected_price)
        end

        it "calculates price for single day when check_in equals check_out" do
          room_availability.update!(price: 150)
          
          request.check_in = room_availability.available_date
          request.check_out = room_availability.available_date
          
          expect(request.calculate_price).to eq(room_availability.price)
        end

        it "returns nil when no room availabilities exist for the date range" do
          request.check_in = 5.years.from_now.to_date
          request.check_out = (5.years.from_now + 2.days).to_date
          
          expect(request.calculate_price).to be_nil
        end
      end

      context "when check_in is missing" do
        it "returns nil" do
          request.check_in = nil
          request.check_out = 12.days.from_now
          
          expect(request.calculate_price).to be_nil
        end
      end

      context "when check_out is missing" do
        it "returns nil" do
          request.check_in = 10.days.from_now
          request.check_out = nil
          
          expect(request.calculate_price).to be_nil
        end
      end

      context "when room is not present" do
        it "returns nil" do
          request.room = nil
          
          expect(request.calculate_price).to be_nil
        end
      end
    end
  end

  describe "class methods" do
    describe ".ransackable_attributes" do
      it "returns empty array" do
        expect(Request.ransackable_attributes).to eq(%w())
      end
    end

    describe ".ransackable_associations" do
      it "returns booking and room" do
        expect(Request.ransackable_associations).to eq(%w(booking room))
      end
    end
  end
end
