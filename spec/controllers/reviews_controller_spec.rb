require "rails_helper"

RSpec.describe ReviewsController, type: :controller do
  let(:user)        { create(:user) }
  let(:other_user)  { create(:user) }
  let(:room_type)   { create(:room_type) }
  let(:room)        { create(:room, room_type: room_type) }
  let(:booking)     { create(:booking, user: user) }
  let(:request_rec) { create(:request, booking: booking, room: room) }

  before { sign_in user }

  describe "GET #index" do
    let!(:my1)   { create(:review, user: user,  request: request_rec) }
    let!(:my2)   { create(:review, user: user,  request: request_rec) }
    let!(:other) { create(:review, user: other_user) }

    context "when user exists" do
      before { get :index, params: { user_id: user.id } }

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "assigns only current user's reviews" do
        expect(assigns(:reviews)).to match_array([my1, my2])
      end
    end

    context "when user not found" do
      before { get :index, params: { user_id: -1 } }

      it "redirects to root" do
        expect(response).to redirect_to(root_path)
      end

      it "sets warning flash (I18n)" do
        expect(flash[:warning]).to eq(I18n.t("reviews.not_found"))
      end
    end
  end

  describe "POST #create" do
    let(:params_valid) do
      {
        user_id: user.id,
        review: { rating: 5, comment: "Great", request_id: request_rec.id, review_status: "pending" }
      }
    end

    context "with valid params" do
      let!(:initial) { Review.count }
      before { post :create, params: params_valid }

      it "creates exactly 1 review" do
        expect(Review.count).to eq(initial + 1)
      end

      it "redirects to user bookings" do
        expect(response).to redirect_to(user_bookings_path(user))
      end

      it "sets success flash (I18n)" do
        expect(flash[:success]).to eq(I18n.t("reviews.create.success"))
      end

      it "sets created review user" do
        expect(Review.last.user).to eq(user)
      end

      it "sets created review request" do
        expect(Review.last.request_id).to eq(request_rec.id)
      end
    end

    context "with invalid params" do
      before do
        allow_any_instance_of(Review).to receive(:save).and_return(false)
        @initial = Review.count
        post :create, params: { user_id: user.id, review: { rating: nil, comment: "" } }
      end

      it "does not create review" do
        expect(Review.count).to eq(@initial)
      end

      it "sets flash.now error (I18n)" do
        expect(flash.now[:error]).to eq(I18n.t("reviews.create.error"))
      end
    end

    context "when user not found" do
      before { post :create, params: params_valid.merge(user_id: -1) }

      it "redirects to root" do
        expect(response).to redirect_to(root_path)
      end

      it "sets warning flash (I18n)" do
        expect(flash[:warning]).to eq(I18n.t("reviews.not_found"))
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:my_review) { create(:review, user: user, request: request_rec) }

    context "success from bookings page" do
      before do
        request.env["HTTP_REFERER"] = user_bookings_path(user)
        @initial = Review.count
        delete :destroy, params: { user_id: user.id, id: my_review.id }
      end

      it "deletes exactly 1 review" do
        expect(Review.count).to eq(@initial - 1)
      end

      it "redirects back to bookings" do
        expect(response).to redirect_to(user_bookings_path(user))
      end

      it "sets success flash (I18n)" do
        expect(flash[:success]).to eq(I18n.t("reviews.destroy.success"))
      end
    end

    context "success from reviews page" do
      before do
        request.env["HTTP_REFERER"] = user_reviews_path(user)
        delete :destroy, params: { user_id: user.id, id: my_review.id }
      end

      it "redirects to reviews index" do
        expect(response).to redirect_to(user_reviews_path(user))
      end
    end

    context "review not found" do
      before { delete :destroy, params: { user_id: user.id, id: -1 } }

      it "redirects to user reviews" do
        expect(response).to redirect_to(user_reviews_path(user))
      end

      it "sets warning flash (I18n)" do
        expect(flash[:warning]).to eq(I18n.t("reviews.not_found"))
      end
    end

    context "user not found" do
      before { delete :destroy, params: { user_id: -1, id: my_review.id } }

      it "redirects to root" do
        expect(response).to redirect_to(root_path)
      end

      it "sets warning flash (I18n)" do
        expect(flash[:warning]).to eq(I18n.t("reviews.not_found"))
      end
    end
  end

  describe "strong params (#review_params)" do
    let(:params) do
      ActionController::Parameters.new(
        user_id: user.id,
        review: {
          rating: 4,
          comment: "ok",
          request_id: request_rec.id,
          review_status: "pending",
          hacked: "x"
        }
      )
    end

    before { allow(controller).to receive(:params).and_return(params) }
    subject(:permitted) { controller.send(:review_params) }

    context "when checking permitted keys" do
      it "permits rating" do
        expect(permitted).to include(:rating)
      end

      it "permits comment" do
        expect(permitted).to include(:comment)
      end

      it "permits request_id" do
        expect(permitted).to include(:request_id)
      end

      it "permits review_status" do
        expect(permitted).to include(:review_status)
      end
    end

    context "when checking rejected keys" do
      it "does not permit hacked" do
        expect(permitted).not_to include(:hacked)
      end
    end
  end
end
