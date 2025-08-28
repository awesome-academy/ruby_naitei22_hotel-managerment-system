require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { build(:user) }
  let!(:another_user) { create(:user) }

  it "is valid with a complete factory" do
    expect(build(:user)).to be_valid
  end

  # ---
  # Validations
  # ---
  describe "#name" do
    it "is not valid when name is blank" do
      user.name = ""
      expect(user).not_to be_valid
    end

    it "adds blank error when name is blank" do
      user.name = ""
      user.valid?
      expect(user.errors[:name]).to include(I18n.t("errors.messages.blank"))
    end

    it "is not valid when name exceeds maximum length" do
      user.name = "a" * (User::NAME_MAX_LENGTH + 1)
      expect(user).not_to be_valid
    end

    it "adds too long error when name exceeds maximum length" do
      user.name = "a" * (User::NAME_MAX_LENGTH + 1)
      user.valid?
      expect(user.errors[:name]).to include(
        I18n.t("errors.messages.too_long", count: User::NAME_MAX_LENGTH)
      )
    end
  end

  describe "#email" do
    it "is not valid when email is blank" do
      user.email = ""
      expect(user).not_to be_valid
    end

    it "adds blank error when email is blank" do
      user.email = ""
      user.valid?
      expect(user.errors[:email]).to include(I18n.t("errors.messages.blank"))
    end

    it "is not valid when email exceeds maximum length" do
      user.email = ("a" * (User::EMAIL_MAX_LENGTH - 10)) + "@example.com"
      expect(user.email.length).to be > User::EMAIL_MAX_LENGTH
      expect(user).not_to be_valid
    end

    it "adds too long error when email exceeds maximum length" do
      user.email = ("a" * (User::EMAIL_MAX_LENGTH - 10)) + "@example.com"
      user.valid?
      expect(user.errors[:email]).to include(
        I18n.t("errors.messages.too_long", count: User::EMAIL_MAX_LENGTH)
      )
    end

    it "is not valid when email is duplicated" do
      user.email = another_user.email
      expect(user).not_to be_valid
    end

    it "adds taken error when email is duplicated" do
      user.email = another_user.email
      user.valid?
      expect(user.errors[:email]).to include(I18n.t("errors.messages.taken"))
    end
  end

  # ---
  # Associations
  # ---
  describe "Associations" do
    it "has many bookings" do
      assoc = described_class.reflect_on_association(:bookings)
      expect(assoc.macro).to eq :has_many
    end

    it "has many reviews" do
      assoc = described_class.reflect_on_association(:reviews)
      expect(assoc.macro).to eq :has_many
    end

    it "destroys dependent bookings on destroy" do
      user = create(:user)
      booking = create(:booking, user: user)

      user.destroy

      expect { booking.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "return the correct bookings" do
      user = create(:user)
      booking1 = create(:booking, user: user)
      booking2 = create(:booking, user: user)
      expect(user.bookings).to contain_exactly(booking1, booking2)
    end

    it "destroy dependent reviews on destroy" do
      user = create(:user)
      room_type = create(:room_type)
      room = create(:room, room_type: room_type)
      booking = create(:booking, user: user)
      request = create(:request, booking: booking, room: room)
      review = create(:review, user: user, request: request)

      user.destroy

      expect { review.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "return the correct reviews" do
      user = create(:user)
      room_type = create(:room_type)
      room = create(:room, room_type: room_type)
      booking = create(:booking, user: user)
      request = create(:request, booking: booking, room: room)
      review1 = create(:review, user: user, request: request)
      review2 = create(:review, user: user, request: request)
      expect(user.reviews).to contain_exactly(review1, review2)
    end
  end

  # ---
  # Methods
  # ---
  describe "Methods" do
    describe "#total_bookings" do
      it "return the number of bookings of the user" do
        user = create(:user)
        create_list(:booking, 3, user: user)
        expect(user.total_bookings).to eq 3
      end
    end

    describe "#total_created_bookings" do
      it "return the number of bookings that not in status draft" do
        user = create(:user)
        create(:booking, user: user, status: :draft)
        create(:booking, user: user, status: :pending)
        create(:booking, user: user, status: :confirmed)
        expect(user.total_created_bookings).to eq 2
      end
    end

    describe "#total_successful_bookings" do
      it "return the number of bookings that in status confirmed or completed" do
        user = create(:user)
        create(:booking, user: user, status: :confirmed)
        create(:booking, user: user, status: :completed)
        create(:booking, user: user, status: :pending)
        expect(user.total_successful_bookings).to eq 2
      end
    end

    describe "#total_cancelled_bookings" do
      it "return the number of bookings that in status cancelled" do
        user = create(:user)
        create(:booking, user: user, status: :cancelled)
        create(:booking, user: user, status: :pending)
        expect(user.total_cancelled_bookings).to eq 1
      end
    end

    describe "#total_pending_bookings" do
      it "return the number of bookings that in status pending" do
        user = create(:user)
        create(:booking, user: user, status: :pending)
        create(:booking, user: user, status: :pending)
        create(:booking, user: user, status: :confirmed)
        expect(user.total_pending_bookings).to eq 2
      end
    end

    describe "#downcase_email" do
      it "downcases email before save" do
        mixed_email = "TeSt@Example.COM"
        user = create(:user, email: mixed_email)
        expect(user.email).to eq mixed_email.downcase
      end
    end
  end
end
