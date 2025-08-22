require "rails_helper"

RSpec.describe Review, type: :model do
  let!(:room_type){create(:room_type)}
  let!(:room){create(:room, room_type: room_type)}
  let!(:user){create(:user)}
  let!(:approver){create(:user, :admin)}
  let!(:booking){create(:booking, user: user)}
  let!(:request){create(:request, booking: booking, room: room)}

  describe "associations" do
    let(:assoc_user){Review.reflect_on_association(:user)}
    let(:assoc_req){Review.reflect_on_association(:request)}
    let(:assoc_app){Review.reflect_on_association(:approved_by)}

    context "with user association" do
      it "has a belongs_to macro" do
        expect(assoc_user.macro).to eq(:belongs_to)
      end
    end

    context "with request association" do
      it "has a belongs_to macro" do
        expect(assoc_req.macro).to eq(:belongs_to)
      end
    end

    context "with approved_by association" do
      it "has a belongs_to macro" do
        expect(assoc_app.macro).to eq(:belongs_to)
      end

      it "has class name User" do
        expect(assoc_app.class_name).to eq("User")
      end

      it "is optional" do
        expect(assoc_app.options[:optional]).to be true
      end
    end

    context "access through associations" do
      let(:review){create(:review, user: user, request: request, approved_by: approver)}
      it "can access user" do
        expect(review.user).to eq(user)
      end

      it "can access approver" do
        expect(review.approved_by).to eq(approver)
      end

      it "can access booking through request" do
        expect(review.booking).to eq(booking)
      end

      it "can access room through request" do
        expect(review.room).to eq(room)
      end

      it "can access room_type through request and room" do
        expect(review.room_type).to eq(room_type)
      end
    end
  end

  describe "before_create" do
    describe "#set_review_status_pending" do
      it "changes the review_status to pending" do
        review = create(:review, user: user, request: request, review_status: :approved)
        expect(review.review_status).to eq("pending")
      end
    end
  end

  describe "delegated methods" do
    let(:review){create(:review, user: user, request: request)}

    describe "#booking" do
      it "returns the associated booking through request" do
        expect(review.booking).to eq(booking)
      end
    end

    describe "#room" do
      it "returns the associated room through request" do
        expect(review.room).to eq(room)
      end
    end

    describe "#room_type" do
      it "returns the room type through request and room" do
        expect(review.room_type).to eq(room.room_type)
      end
    end
  end

  describe "scopes" do
    describe ".by_review_id" do
      let!(:review1){create(:review)}
      let!(:review2){create(:review)}
      let!(:review3){create(:review)}

      it "returns reviews ordered by id in descending order" do
        reviews = Review.by_review_id
        expect(reviews).to eq([review3, review2, review1])
      end
    end
  end

  describe ".ransackable attributes" do
    it "allows searching by review_status and rating" do
      ransackable_attrs = Review.ransackable_attributes
      expect(ransackable_attrs).to include("review_status", "rating")
    end
  end

  describe ".ransackable associations" do
    it "allows searching through user, request, booking, and room" do
      ransackable_assocs = Review.ransackable_associations
      expect(ransackable_assocs).to include("user", "request", "booking", "room")
    end
  end

  describe "status transitions" do
    let(:review){create(:review, user: user, request: request)}

    context "when approved by an admin" do
      before do
        review.update(review_status: :approved, approved_by: approver)
      end

      it "is marked as approved" do
        expect(review.review_status_approved?).to be true
      end

      it "stores the approver" do
        expect(review.approved_by).to eq(approver)
      end
    end

    context "when rejected by an admin" do
      before do
        review.update(review_status: :rejected, approved_by: approver)
      end

      it "is marked as rejected" do
        expect(review.review_status_rejected?).to be true
      end

      it "stores the approver" do
        expect(review.approved_by).to eq(approver)
      end
    end
  end
end
