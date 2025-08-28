require "rails_helper"

RSpec.describe Room, type: :model do
  describe "associations" do
    let(:room) { create(:room) }

    it "belongs to room_type" do
      expect(room.room_type).to be_present
    end

    it "has many room_amenities and destroys them" do
      ra = create(:room_amenity, room: room)
      expect(room.room_amenities).to include(ra)
    end

    it "destroys dependent room_amenities when room destroyed" do
      ra = create(:room_amenity, room: room)
      room.destroy
      expect(RoomAmenity.find_by(id: ra.id)).to be_nil
    end

    it "has many amenities through room_amenities" do
      assoc = described_class.reflect_on_association(:amenities)
      expect(assoc.macro).to eq(:has_many)
    end

    it "amenities association uses through room_amenities" do
      assoc = described_class.reflect_on_association(:amenities)
      expect(assoc.options[:through]).to eq(:room_amenities)
    end

    it "has many room_availability_requests through room_availabilities" do
      assoc = described_class.reflect_on_association(:room_availability_requests)
      expect(assoc.macro).to eq(:has_many)
    end

    it "room_availability_requests association uses through room_availabilities" do
      assoc = described_class.reflect_on_association(:room_availability_requests)
      expect(assoc.options[:through]).to eq(:room_availabilities)
    end

    it "has many requests" do
      booking = create(:booking, user: create(:user))
      req = create(:request, room: room, booking: booking)
      expect(room.requests).to include(req)
    end

    it "has many reviews through requests" do
      booking = create(:booking, user: create(:user))
      req = create(:request, room: room, booking: booking)
      review = create(:review, :approved, request: req, user: booking.user)
      expect(room.reviews).to include(review)
    end
  end

  describe "validations" do
    context "room_number" do
      it "is invalid without room_number" do
        r = build(:room, room_number: "")
        expect(r).not_to be_valid
      end

      it "adds presence error" do
        r = build(:room, room_number: "").tap(&:valid?)
        expect(r.errors[:room_number]).to include(I18n.t("errors.messages.blank"))
      end

      it "is invalid when duplicated" do
        existing = create(:room)
        dup = build(:room, room_number: existing.room_number)
        expect(dup).not_to be_valid
      end

      it "adds taken error when duplicated" do
        existing = create(:room)
        dup = build(:room, room_number: existing.room_number).tap(&:valid?)
        expect(dup.errors[:room_number]).to include(I18n.t("errors.messages.taken"))
      end
    end

    context "room_type" do
      it "is invalid without room_type" do
        r = build(:room, room_type: nil)
        expect(r).not_to be_valid
      end
    end

    context "capacity" do
      it "is invalid without capacity" do
        r = build(:room, capacity: nil)
        expect(r).not_to be_valid
      end

      it "adds presence error" do
        r = build(:room, capacity: nil).tap(&:valid?)
        expect(r.errors[:capacity]).to include(I18n.t("errors.messages.blank"))
      end

      it "is invalid when not integer" do
        r = build(:room, capacity: 2.5)
        expect(r).not_to be_valid
      end

      it "adds not a number error when not numeric" do
        r = build(:room, capacity: "abc").tap(&:valid?)
        expect(r.errors[:capacity]).to include(I18n.t("errors.messages.not_a_number"))
      end

      it "is invalid when <= 0" do
        r = build(:room, capacity: 0)
        expect(r).not_to be_valid
      end

      it "adds greater than error when <= 0" do
        r = build(:room, capacity: 0).tap(&:valid?)
        expect(r.errors[:capacity]).to include(I18n.t("errors.messages.greater_than", count: 0))
      end
    end

    context "description" do
      it "is invalid without description" do
        r = build(:room, description: "")
        expect(r).not_to be_valid
      end

      it "adds blank error" do
        r = build(:room, description: "").tap(&:valid?)
        expect(r.errors[:description]).to include(I18n.t("errors.messages.blank"))
      end

      it "is invalid when length > 140" do
        r = build(:room, description: "a" * (Room::DIGIT_140 + 1))
        expect(r).not_to be_valid
      end

      it "adds too long error" do
        r = build(:room, description: "a" * (Room::DIGIT_140 + 1)).tap(&:valid?)
        expect(r.errors[:description]).to include(I18n.t("errors.messages.too_long", count: Room::DIGIT_140))
      end
    end

    context "price fields on create" do
      it "require price_from_date" do
        r = build(:room, price_from_date: nil)
        expect(r).not_to be_valid
      end

      it "adds blank error for price_from_date" do
        r = build(:room, price_from_date: nil).tap(&:valid?)
        expect(r.errors[:price_from_date]).to include(I18n.t("errors.messages.blank"))
      end

      it "require price_to_date" do
        r = build(:room, price_to_date: nil)
        expect(r).not_to be_valid
      end

      it "adds blank error for price_to_date" do
        r = build(:room, price_to_date: nil).tap(&:valid?)
        expect(r.errors[:price_to_date]).to include(I18n.t("errors.messages.blank"))
      end

      it "require price" do
        r = build(:room, price: nil)
        expect(r).not_to be_valid
      end

      it "adds blank error for price" do
        r = build(:room, price: nil).tap(&:valid?)
        expect(r.errors[:price]).to include(I18n.t("errors.messages.blank"))
      end

      it "adds greater than error when price <= 0" do
        r = build(:room, price: 0).tap(&:valid?)
        expect(r.errors[:price]).to include(I18n.t("errors.messages.greater_than", count: 0))
      end
    end

    context "price fields partial update" do
      it "requires all price fields if one provided" do
        persisted = create(:room)
        persisted.update(price: 200, price_from_date: nil)
        expect(persisted.errors[:price_from_date]).to include(I18n.t("errors.messages.blank"))
      end
    end

    context "price date validations" do
      it "adds in_past error when price_from_date in past" do
        r = build(:room, price_from_date: Date.yesterday)
        r.valid?
        expect(r.errors[:price_from_date]).to include(I18n.t("activerecord.errors.models.room.attributes.price_from_date.in_past"))
      end

      it "adds in_past error when price_to_date in past" do
        r = build(:room, price_to_date: Date.yesterday)
        r.valid?
        expect(r.errors[:price_to_date]).to include(I18n.t("activerecord.errors.models.room.attributes.price_to_date.in_past"))
      end

      it "adds before_start_date error when price_from_date > price_to_date" do
        r = build(:room, price_from_date: Date.today + 10, price_to_date: Date.today + 5)
        r.valid?
        expect(r.errors[:price_to_date]).to include(I18n.t("activerecord.errors.models.room.attributes.price_to_date.before_start_date"))
      end
    end
  end

  describe "callbacks" do
    context "before_destroy check_for_requests" do
      it "prevents destroy when has unavailable status requests" do
        room = create(:room)
        booking = create(:booking, user: create(:user))
        create(:request, :pending, room: room, booking: booking)
        expect(room.destroy).to be_falsey
      end

      it "adds error when destroy blocked due to requests" do
        room = create(:room)
        booking = create(:booking, user: create(:user))
        create(:request, :pending, room: room, booking: booking)
        room.destroy
        expect(room.errors[:base]).to include(I18n.t("activerecord.errors.models.room.attributes.base.cannot_delete_with_requests"))
      end

      it "keeps room record when destroy blocked" do
        room = create(:room)
        booking = create(:booking, user: create(:user))
        create(:request, :pending, room: room, booking: booking)
        room.destroy
        expect(Room.exists?(room.id)).to be true
      end

      it "allows destroy when only draft requests" do
        room = create(:room)
        booking = create(:booking, user: create(:user))
        create(:request, :draft, room: room, booking: booking)
        expect(room.destroy).to be_truthy
      end

      it "removes room when destroyed with only draft requests" do
        room = create(:room)
        booking = create(:booking, user: create(:user))
        create(:request, :draft, room: room, booking: booking)
        room.destroy
        expect(Room.exists?(room.id)).to be false
      end
    end
  end

  describe "instance methods" do
    describe "#average_rating" do
      it "returns 0 with no approved reviews" do
        expect(create(:room).average_rating).to eq(0)
      end
    end

    describe "#number_of_rating" do
      it "returns 0 with no approved reviews" do
        expect(create(:room).number_of_rating).to eq(0)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns room_number" do
      expect(Room.ransackable_attributes).to eq(["room_number"])
    end
  end

  describe ".ransackable_associations" do
    it "returns room_type" do
      expect(Room.ransackable_associations).to eq(["room_type"])
    end
  end
end
