require "rails_helper"

RSpec.describe RoomAvailabilityRequest, type: :model do
  let(:room_availability_request) { build(:room_availability_request) }
  let!(:persisted) { create(:room_availability_request) }

  it "is valid with a complete factory" do
    expect(room_availability_request).to be_valid
  end

  # ---
  # Associations
  # ---
  describe "Associations" do
    it "belongs to room_availability" do
      assoc = described_class.reflect_on_association(:room_availability)
      expect(assoc.macro).to eq :belongs_to
    end

    it "belongs to request" do
      assoc = described_class.reflect_on_association(:request)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  # ---
  # Validations (implicit via belongs_to requirements)
  # ---
  describe "Validations" do
    context "room_availability" do
      it "is not valid without room_availability" do
        rar = build(:room_availability_request, room_availability: nil)
        expect(rar).not_to be_valid
      end
    end

    context "request" do
      it "is not valid without request" do
        rar = build(:room_availability_request, request: nil)
        expect(rar).not_to be_valid
      end
    end
  end
end
