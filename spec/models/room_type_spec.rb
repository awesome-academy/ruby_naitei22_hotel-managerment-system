require "rails_helper"

RSpec.describe RoomType, type: :model do
  let(:room_type) { build(:room_type) }
  let!(:another_room_type) { create(:room_type) }

  it "is valid with a complete factory" do
    expect(build(:room_type)).to be_valid
  end

  # ---
  # Validations
  # ---
  describe "#name" do
    it "is not valid when name is blank" do
      room_type.name = ""
      expect(room_type).not_to be_valid
    end

    it "adds blank error when name is blank" do
      room_type.name = ""
      room_type.valid?
      expect(room_type.errors[:name]).to include(I18n.t("errors.messages.blank"))
    end

    it "is not valid when name is duplicated" do
      room_type.name = another_room_type.name
      expect(room_type).not_to be_valid
    end

    it "adds taken error when name is duplicated" do
      room_type.name = another_room_type.name
      room_type.valid?
      expect(room_type.errors[:name]).to include(I18n.t("errors.messages.taken"))
    end
  end

  describe "#description" do
    it "is not valid when description is blank" do
      room_type.description = ""
      expect(room_type).not_to be_valid
    end

    it "adds blank error when description is blank" do
      room_type.description = ""
      room_type.valid?
      expect(room_type.errors[:description]).to include(I18n.t("errors.messages.blank"))
    end
  end

  # ---
  # Associations
  # ---
  describe "Associations" do
    it "has many rooms" do
      assoc = described_class.reflect_on_association(:rooms)
      expect(assoc.macro).to eq :has_many
    end

    it "destroys dependent rooms on destroy when callback is skipped" do
      room_type = create(:room_type)
      room = create(:room, room_type: room_type)

      # skip callback
      allow(room_type).to receive(:check_for_rooms)

      room_type.destroy
      expect { room.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns the correct rooms" do
      room_type = create(:room_type)
      room1 = create(:room, room_type: room_type)
      room2 = create(:room, room_type: room_type)
      expect(room_type.rooms).to contain_exactly(room1, room2)
    end
  end

  # ---
  # Room Count
  # ---
  describe "#number_of_rooms" do
    let(:room_type) { create(:room_type) }

    it "returns the number of rooms associated with the room type" do
      create_list(:room, 3, room_type: room_type)
      expect(room_type.number_of_rooms).to eq(3)
    end
  end

  # ---
  # Callbacks
  # ---
  describe "Callbacks" do
    context "when room type has rooms" do
      it "does not allow destroy" do
        room_type = create(:room_type)
        create(:room, room_type: room_type)

        result = room_type.destroy

        expect(result).to be_falsey
      end

      it "adds an error message" do
        room_type = create(:room_type)
        create(:room, room_type: room_type)

        room_type.destroy

        expect(room_type.errors[:base]).to include(
          I18n.t("activerecord.errors.models.room_type.attributes.base.cannot_delete_with_rooms")
        )
      end
    end
  end
end
