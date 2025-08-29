require "rails_helper"

RSpec.describe Guest, type: :model do
  let!(:request) {create(:request)}
  let!(:guest) {create(:guest, request: request)}

  describe "associations" do
    it "belongs to a request" do
      expect(guest.request).to eq(request)
    end

    it "has many attached images" do
      expect(guest).to respond_to(:images)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(guest).to be_valid
    end

    it "is invalid without full_name" do
      guest.full_name = nil
      guest.valid?
      expect(guest.errors.of_kind?(:full_name, :blank)).to be true
    end

    it "is invalid without identity_type" do
      guest.identity_type = nil
      guest.valid?
      expect(guest.errors.of_kind?(:identity_type, :blank)).to be true
    end

    it "is invalid without identity_number" do
      guest.identity_number = nil
      guest.valid?
      expect(guest.errors.of_kind?(:identity_number, :blank)).to be true
    end

    it "is invalid without identity_issued_date" do
      guest.identity_issued_date = nil
      guest.valid?
      expect(guest.errors.of_kind?(:identity_issued_date, :blank)).to be true
    end

    it "is invalid without identity_issued_place" do
      guest.identity_issued_place = nil
      guest.valid?
      expect(guest.errors.of_kind?(:identity_issued_place, :blank)).to be true
    end        

    it "is invalid with duplicate identity_number" do
      create(:guest, identity_number: "123456789012")
      guest.identity_number = "123456789012"
      guest.valid?
      expect(guest.errors.of_kind?(:identity_number, :taken)).to be true
    end
  end

  describe "#validate_identity_date" do
    context "when identity_issued_date is in the future" do
      it "adds error to identity_issued_date" do
        guest.identity_issued_date = 1.day.from_now
        guest.valid?
        expect(guest.errors.of_kind?(:identity_issued_date, :future)).to be true
      end
    end

    context "when identity_issued_date is today" do
      it "is valid" do
        guest.identity_issued_date = Time.zone.today
        expect(guest).to be_valid
      end
    end

    context "when identity_issued_date is in the past" do
      it "is valid" do
        guest.identity_issued_date = 1.day.ago
        expect(guest).to be_valid
      end
    end
  end

  describe "#validate_national_id_identity_number" do
    context "when identity_type is national_id" do
      it "is valid with 12 digit number" do
        guest.identity_type = :national_id
        guest.identity_number = "123456789012"
        expect(guest).to be_valid
      end

      it "is invalid with less than 12 digits" do
        guest.identity_type = :national_id
        guest.identity_number = "12345678901"
        guest.valid?
        expect(guest.errors.of_kind?(:identity_number, :invalid_national_id)).to be true
      end

      it "is invalid with incorrect format" do
        guest.identity_type = :national_id
        guest.identity_number = "1234567890123"
        guest.valid?
        expect(guest.errors.of_kind?(:identity_number, :invalid_national_id)).to be true
      end
    end

    context "when identity_type is identity_number" do
      it "is valid with 12 digit number" do
        guest.identity_type = :identity_number
        guest.identity_number = "123456789012"
        expect(guest).to be_valid
      end

      it "is invalid with incorrect format" do
        guest.identity_type = :identity_number
        guest.identity_number = "12345678901"
        guest.valid?
        expect(guest.errors.of_kind?(:identity_number, :invalid_national_id)).to be true
      end
    end
  end

  describe "#validate_passport" do
    context "when identity_type is passport" do
      it "is valid with correct format (letter + 7 digits)" do
        guest.identity_type = :passport
        guest.identity_number = "a1234567"
        expect(guest).to be_valid
      end

      it "is invalid with incorrect format" do
        guest.identity_type = :passport
        guest.identity_number = "A1234567"
        guest.valid?
        expect(guest.errors.of_kind?(:identity_number, :invalid_passport)).to be true
      end

      it "is invalid with wrong number of digits" do
        guest.identity_type = :passport
        guest.identity_number = "a123456"
        guest.valid?
        expect(guest.errors.of_kind?(:identity_number, :invalid_passport)).to be true
      end

      it "is invalid without letter prefix" do
        guest.identity_type = :passport
        guest.identity_number = "1234567"
        guest.valid?
        expect(guest.errors.of_kind?(:identity_number, :invalid_passport)).to be true
      end
    end
  end

  describe "#validate_images" do
    context "when no images are attached" do
      it "is valid" do
        expect(guest).to be_valid
      end
    end

    context "when images are attached" do
      it "is valid with valid image format" do
        image_double = double("image", content_type: "image/png")
        allow(guest.images).to receive(:attached?).and_return(true)
        allow(guest.images).to receive(:each).and_yield(image_double)
        allow(guest.images).to receive(:count).and_return(1)
        
        expect(guest).to be_valid
      end

      it "is invalid with invalid image format" do
        image_double = double("image", content_type: "text/plain")
        allow(guest.images).to receive(:attached?).and_return(true)
        allow(guest.images).to receive(:each).and_yield(image_double)
        allow(guest.images).to receive(:count).and_return(1)
        
        guest.valid?
        expect(guest.errors.of_kind?(:images, :invalid_format)).to be true
      end

      it "is invalid with more than 2 images" do
        image_double = double("image", content_type: "image/png")
        allow(guest.images).to receive(:attached?).and_return(true)
        allow(guest.images).to receive(:each).and_yield(image_double)
        allow(guest.images).to receive(:count).and_return(3)
        
        guest.valid?
        expect(guest.errors.of_kind?(:images, :too_many)).to be true
      end
    end
  end
end
