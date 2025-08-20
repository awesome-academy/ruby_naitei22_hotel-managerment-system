require "rails_helper"

RSpec.describe Request, type: :model do
  around do |example|
    I18n.with_locale(:en) { example.run }
  end

  describe "associations" do
    let(:user) { create(:user) }
    let(:room) { create(:room) }
    let(:booking) { create(:booking) }
    let(:room_availability) { create(:room_availability, room: room) }
    let(:request) do
      create(
        :request,
        booking: booking,
        room: room,
        status: :draft,
        check_in: Date.today,
        check_out: Date.tomorrow
      )
    end

    it "belongs to booking" do
      expect(request.booking).to eq(booking)
    end

    it "belongs to room" do
      expect(request.room).to eq(room)
    end

    it "has many reviews" do
      review = request.reviews.create!(user: user)
      expect(request.reviews).to include(review)
    end

    it "destroys associated reviews when request is destroyed" do
      review = request.reviews.create!(user: user)
      request.destroy
      expect(Review.find_by(id: review.id)).to be_nil
    end

    it "has many room_availability_requests" do
      rar = request.room_availability_requests.create!(room_availability: room_availability)
      expect(request.room_availability_requests).to include(rar)
    end

    it "destroys associated room_availability_requests when request is destroyed" do
      rar = request.room_availability_requests.create!(room_availability: room_availability)
      request.destroy
      expect(RoomAvailabilityRequest.find_by(id: rar.id)).to be_nil
    end

    it "has many room_availabilities through room_availability_requests" do
      request.room_availability_requests.create!(room_availability: room_availability)
      expect(request.room_availabilities).to include(room_availability)
    end

    it "has many guests" do
      guest = create(:guest, request: request)
      expect(request.guests).to include(guest)
    end

    it "destroys associated guests when request is destroyed" do
      guest = create(:guest, request: request)
      request.destroy
      expect(Guest.find_by(id: guest.id)).to be_nil
    end
  end

  describe "validations" do
    context "check_in presence" do
      it "is invalid without check_in" do
        request = build(:request, check_in: nil)
        expect(request).not_to be_valid
      end

      it "sets flash[:errors] without check_in" do
        request = build(:request, check_in: nil).tap(&:valid?)
        expected_message = I18n.t("errors.messages.blank")
        expect(request.errors[:check_in]).to include(expected_message)
      end
    end

    context "check_out presence" do
      it "is invalid without check_out" do
        request = build(:request, check_out: nil)
        expect(request).not_to be_valid
      end

      it "sets flash[:errors] without check_out" do
        request = build(:request, check_out: nil).tap(&:valid?)
        expected_message = I18n.t("errors.messages.blank")
        expect(request.errors[:check_out]).to include(expected_message)
      end
    end

    context "with invalid check_in/check_out" do
      let(:request) { build(:request, check_in: Date.today, check_out: Date.yesterday) }

      it "adds error when check_out < check_in" do
        expect(request).not_to be_valid
      end

      it "adds proper error message" do
        request.valid?
        expected_message = I18n.t("activerecord.errors.models.request.attributes.check_out.check_in_before_check_out")
        expect(request.errors[:check_out]).to include(expected_message)
      end
    end

    context "with past check_in" do
      let(:request) { build(:request, check_in: Date.yesterday, check_out: Date.today) }

      it "adds error when check_in < today" do
        expect(request).not_to be_valid
      end

      it "adds proper error message" do
        request.valid?
        expected_message = I18n.t("activerecord.errors.models.request.attributes.check_in.future")
        expect(request.errors[:check_in]).to include(expected_message)
      end
    end
  end

  describe "callbacks" do
    context "after_initialize" do
      it "sets default status to draft" do
        request = Request.new
        expect(request.status).to eq("draft")
      end
    end

    context "after_update" do
      let(:room) { create(:room) }
      let(:room_availability) { create(:room_availability, room: room) }
      let(:request) do
        create(
          :request,
          room: room,
          status: :draft,
          check_in: Date.today,
          check_out: Date.tomorrow
        )
      end

      before { request.room_availabilities << room_availability }

      it "sets is_available=false when status in UNAVAILABLE_STATUSES" do
        request.update!(status: :pending)
        expect(room_availability.reload.is_available).to eq(false)
      end

      it "sets is_available=true when status is not in UNAVAILABLE_STATUSES" do
        request.update!(status: :declined)
        expect(room_availability.reload.is_available).to eq(true)
      end
    end
  end

  describe "#calculate_price" do
    let(:room) { create(:room) }
    let(:request) { build(:request, room: room, check_in: check_in, check_out: check_out) }

    context "when check_in or check_out or room is missing" do
      let(:check_in) { nil }
      let(:check_out) { nil }

      it "returns nil" do
        expect(request.calculate_price).to be_nil
      end
    end

    context "when check_in == check_out" do
      let(:check_in) { Date.today }
      let(:check_out) { Date.today }

      it "returns nil if no availabilities" do
        expect(request.calculate_price).to be_nil
      end

      it "returns sum of prices if availabilities exist" do
        create(:room_availability, room: room, available_date: check_in, price: 200)
        expect(request.calculate_price).to eq(200)
      end
    end

    context "when check_in != check_out" do
      let(:check_in) { Date.today }
      let(:check_out) { Date.today + 2 }

      it "returns nil if no availabilities" do
        expect(request.calculate_price).to be_nil
      end

      it "returns sum of prices if availabilities exist" do
        create(:room_availability, room: room, available_date: check_in, price: 100)
        create(:room_availability, room: room, available_date: check_in + 1, price: 150)
        expect(request.calculate_price).to eq(250)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns an empty array" do
      expect(Request.ransackable_attributes).to eq([])
    end
  end

  describe ".ransackable_associations" do
    it "returns booking and room" do
      expect(Request.ransackable_associations).to match_array(["booking", "room"])
    end
  end
end
