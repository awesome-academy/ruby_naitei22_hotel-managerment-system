require "rails_helper"

RSpec.describe Amenity, type: :model do
  let(:amenity) { build(:amenity) }
  let!(:another_amenity) { create(:amenity) }

  it "is valid with a complete factory" do
    expect(build(:amenity)).to be_valid
  end

  # ---
  # Validations
  # ---
  describe "#name" do
    it "is not valid when name is blank" do
      amenity.name = ""
      expect(amenity).not_to be_valid
    end

    it "adds blank error when name is blank" do
      amenity.name = ""
      amenity.valid?
      expect(amenity.errors[:name]).to include(I18n.t("errors.messages.blank"))
    end
  end

  describe "#description" do
    it "is valid when description is blank (optional field)" do
      amenity.description = ""
      expect(amenity).to be_valid
    end

    it "is not valid when description is longer than 255 characters" do
      amenity.description = "a" * 256
      expect(amenity).not_to be_valid
    end

    it "adds too long error when description exceeds 255 characters" do
      amenity.description = "a" * 256
      amenity.valid?
      expect(amenity.errors[:description]).to include(I18n.t("errors.messages.too_long", count: 255))
    end
  end

  # ---
  # Associations
  # ---
  describe "Associations" do
    it "has many room_amenities" do
      assoc = described_class.reflect_on_association(:room_amenities)
      expect(assoc.macro).to eq :has_many
    end

    it "has many rooms through room_amenities" do
      assoc = described_class.reflect_on_association(:rooms)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:through]).to eq :room_amenities
    end

    it "destroys dependent room_amenities on destroy when callback is skipped" do
      amenity = create(:amenity)
      ra = create(:room_amenity, amenity: amenity)

      # skip callback
      allow(amenity).to receive(:check_for_rooms)

      amenity.destroy
      expect { ra.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  # ---
  # Callbacks
  # ---
  describe "Callbacks" do
    context "when amenity has no rooms" do
      it "allows destroy" do
        amenity = create(:amenity)
        expect(amenity.destroy).to be_truthy
      end
    end
  end

  # ---
  # Class methods
  # ---
  describe ".ransackable_attributes" do
    it "returns the searchable attributes" do
      expect(described_class.ransackable_attributes).to match_array(%w(name description))
    end
  end
end
