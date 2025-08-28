require "rails_helper"

RSpec.describe ReviewsController, type: :controller do
  let(:user) { create(:user) }
  let(:request_record) { create(:request, :checked_out, booking: create(:booking, user: user)) }
  let!(:review) { create(:review, user: user, request: request_record) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index, params: { user_id: user.id } }

    it "assigns @reviews for the user" do
      expect(assigns(:reviews)).to include(review)
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        user_id: user.id,
        review: {
          rating: 5,
          comment: "Great stay",
          request_id: request_record.id
        }
      }
    end

    let(:invalid_params) do
      {
        user_id: user.id,
        review: {
          rating: nil,
          comment: "",
          request_id: request_record.id
        }
      }
    end

    context "with valid params" do
      it "creates a new review" do
        expect do
          post :create, params: valid_params
        end.to change(Review, :count).by(1)
      end

      it "sets success flash and redirects to bookings" do
        post :create, params: valid_params
        expect(flash[:success]).to eq(I18n.t("reviews.create.success"))
        expect(response).to redirect_to(user_bookings_path(user))
      end
    end
  end

  describe "DELETE #destroy" do
    context "when review exists" do
      it "destroys the review" do
        expect do
          delete :destroy, params: { user_id: user.id, id: review.id }
        end.to change(Review, :count).by(-1)
      end

      it "sets success flash and redirects" do
        delete :destroy, params: { user_id: user.id, id: review.id }
        expect(flash[:success]).to eq(I18n.t("reviews.destroy.success"))
        expect(response).to redirect_to(user_reviews_path(user))
      end
    end

    context "when review does not exist" do
      before do
        delete :destroy, params: { user_id: user.id, id: -1 }
      end

      it "sets warning flash" do
        expect(flash[:warning]).to eq(I18n.t("reviews.not_found"))
      end

      it "redirects to user reviews path" do
        expect(response).to redirect_to(user_reviews_path(user))
      end
    end
  end
end
