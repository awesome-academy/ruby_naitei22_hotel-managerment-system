require "rails_helper"

RSpec.describe RoomAvailability, type: :model do
  let(:room) { create(:room) }
  let(:room_availability) { create(:room_availability, room: room) }

  describe "associations" do
    it "belongs to room" do
      expect(room_availability.room).to eq(room)
    end

    it "has one room_type through room" do
      expect(room_availability.room_type).to eq(room.room_type)
    end

    it "has many room_availability_requests and destroys them" do
      rar = RoomAvailabilityRequest.create!(room_availability: room_availability, request: create(:request))
      expect(room_availability.room_availability_requests).to include(rar)
    end

    it "destroys dependent room_availability_requests" do
      rar = RoomAvailabilityRequest.create!(room_availability: room_availability, request: create(:request))
      room_availability.destroy
      expect(RoomAvailabilityRequest.find_by(id: rar.id)).to be_nil
    end

    it "has many requests through room_availability_requests" do
      rar = RoomAvailabilityRequest.create!(room_availability: room_availability, request: create(:request))
      expect(room_availability.requests).to include(rar.request)
    end
  end

  describe "validations" do
    context "available_date" do
      it "is invalid without available_date" do
        ra = build(:room_availability, available_date: nil)
        expect(ra).not_to be_valid
      end

      it "adds blank error for available_date" do
        ra = build(:room_availability, available_date: nil).tap(&:valid?)
        expect(ra.errors[:available_date]).to include(I18n.t("errors.messages.blank"))
      end

      it "validates uniqueness scoped to room" do
        room2 = create(:room)
        existing = create(:room_availability, room: room2)
        dup = build(:room_availability, room: room2)
        # Assign same date after build to avoid passing available_date param directly
        dup.available_date = existing.available_date
        expect(dup).not_to be_valid
      end

      it "adds taken error for available_date uniqueness" do
        room2 = create(:room)
        existing = create(:room_availability, room: room2)
        dup = build(:room_availability, room: room2)
        dup.available_date = existing.available_date
        dup.validate
        expect(dup.errors[:available_date]).to include(I18n.t("errors.messages.taken"))
      end
    end

    context "room" do
      it "is invalid without room" do
        ra = build(:room_availability, room: nil)
        expect(ra).not_to be_valid
      end
    end

    context "is_available inclusion" do
      it "is invalid when nil" do
        ra = build(:room_availability, is_available: nil)
        expect(ra).not_to be_valid
      end

      it "adds inclusion error for is_available when nil" do
        ra = build(:room_availability, is_available: nil).tap(&:valid?)
        expect(ra.errors[:is_available]).to include(I18n.t("errors.messages.inclusion"))
      end
    end
  end

  describe "scopes" do
    let!(:room) { create(:room) }
    let!(:ra_available) { create(:room_availability, room: room, is_available: true) }
    let!(:ra_unavailable) { create(:room_availability, room: room, is_available: false) }

    describe ".available" do
      it "returns records with is_available true" do
        expect(described_class.available).to include(ra_available)
      end

      it "does not return records with is_available false" do
        expect(described_class.available).not_to include(ra_unavailable)
      end
    end

    describe ".unavailable" do
      it "returns records with is_available false" do
        expect(described_class.unavailable).to include(ra_unavailable)
      end

      it "does not return records with is_available true" do
        expect(described_class.unavailable).not_to include(ra_available)
      end
    end

    describe ".ordered" do
      it "orders by available_date asc then room_number asc" do
        ordered = described_class.ordered
        expect(ordered).to eq(ordered.sort_by { |r| [r.available_date, r.room.room_number] })
      end
    end
  end

  describe "instance methods" do
    describe "#status" do
      it "returns :available when is_available true" do
        ra = build(:room_availability, is_available: true)
        expect(ra.status).to eq(:available)
      end

      it "returns :unavailable when is_available false" do
        ra = build(:room_availability, is_available: false)
        expect(ra.status).to eq(:unavailable)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns available_date and is_available" do
      expect(described_class.ransackable_attributes).to match_array(["available_date", "is_available"])
    end
  end

  describe ".ransackable_associations" do
    it "returns room and room_type" do
      expect(described_class.ransackable_associations).to match_array(["room", "room_type"])
    end
  end
end
