require "rails_helper"

RSpec.describe ReviewsController, type: :controller do
  let(:user) { create(:user) }
  let(:booking) { create(:booking, user: user) }
  let(:request_record) { create(:request, status: :pending, booking: booking) }
  let!(:review) { create(:review, user: user, request: request_record) }

  before { sign_in user }

  describe "GET #index" do
    it "returns success" do
      get :index, params: { user_id: user.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns @reviews" do
      get :index, params: { user_id: user.id }
      expect(assigns(:reviews)).to eq([review])
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) do
        { user_id: user.id,
          review: { rating: 5, comment: "Nice", request_id: request_record.id, review_status: "approved" } }
      end

      it "creates a new review" do
        expect {
          post :create, params: valid_params
        }.to change(Review, :count).by(1)
      end

      it "sets success flash" do
        post :create, params: valid_params
        expect(flash[:success]).to eq(I18n.t("reviews.create.success"))
      end

      it "redirects to bookings" do
        post :create, params: valid_params
        expect(response).to redirect_to(user_bookings_path(user))
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { user_id: user.id, review: { rating: nil, comment: "" } } }

      it "does not create review" do
        expect {
          post :create, params: invalid_params
        }.not_to change(Review, :count)
      end

      it "renders error flash.now" do
        post :create, params: invalid_params
        expect(flash.now[:error]).to eq(I18n.t("reviews.create.error"))
      end
    end
  end

  describe "DELETE #destroy" do
    context "when destroy succeeds" do
      it "deletes review" do
        expect {
          delete :destroy, params: { user_id: user.id, id: review.id }
        }.to change(Review, :count).by(-1)
      end

      it "sets success flash" do
        delete :destroy, params: { user_id: user.id, id: review.id }
        expect(flash[:success]).to eq(I18n.t("reviews.destroy.success"))
      end

      it "redirects to reviews path" do
        delete :destroy, params: { user_id: user.id, id: review.id }
        expect(response).to redirect_to(user_reviews_path(user))
      end
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Review).to receive(:destroy).and_return(false)
      end

      it "does not delete review" do
        expect {
          delete :destroy, params: { user_id: user.id, id: review.id }
        }.not_to change(Review, :count)
      end

      it "sets error flash" do
        delete :destroy, params: { user_id: user.id, id: review.id }
        expect(flash[:error]).to eq(I18n.t("reviews.destroy.error"))
      end
    end
  end
end
