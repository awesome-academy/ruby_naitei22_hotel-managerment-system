require "rails_helper"

RSpec.describe RoomAmenity, type: :model do
  let(:room_amenity) { build(:room_amenity) }
  let!(:persisted) { create(:room_amenity) }

  it "is valid with a complete factory" do
    expect(build(:room_amenity)).to be_valid
  end

  # ---
  # Associations
  # ---
  describe "Associations" do
    it "belongs to room" do
      assoc = described_class.reflect_on_association(:room)
      expect(assoc.macro).to eq :belongs_to
    end

    it "belongs to amenity" do
      assoc = described_class.reflect_on_association(:amenity)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  # ---
  # Validations (implicit via belongs_to requirements)
  # ---
  describe "Validations" do
    context "room" do
      it "is not valid without room" do
        ra = build(:room_amenity, room: nil)
        expect(ra).not_to be_valid
      end
    end

    context "amenity" do
      it "is not valid without amenity" do
        ra = build(:room_amenity, amenity: nil)
        expect(ra).not_to be_valid
      end
    end
  end
end
