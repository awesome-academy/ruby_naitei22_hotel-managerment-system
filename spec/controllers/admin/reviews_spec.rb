require "rails_helper"

RSpec.describe Admin::ReviewsController, type: :controller do
  let(:admin) {create(:user, :admin)}
  let(:review) {create(:review)}

  before do
    sign_in admin
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "assigns @reviews" do
      get :index
      expect(assigns(:reviews)).to include(review)
    end

    it "assigns @q for ransack search" do
      get :index
      expect(assigns(:q)).to be_present
    end

    context "with pagination" do
      let!(:reviews) { create_list(:review, 15) }
      let(:pagy) { assigns(:pagy) }
      before do
        get :index
      end

      it "assigns @pagy" do
        expect(pagy).to be_present
      end

      it "has 10 items" do
        expect(pagy.vars[:items]).to eq(Settings.default.digit_10)
      end

      it "has 2 pages" do
        expect(pagy.pages).to eq(2)
      end
    end
  end

  describe "GET #show" do
    context "with valid review id" do
      it "returns a successful response" do
        get :show, params: {id: review.id}
        expect(response).to have_http_status(:ok)
      end

      it "assigns @review" do
        get :show, params: {id: review.id}
        expect(assigns(:review)).to eq(review)
      end
    end

    context "with invalid review id" do
      it "redirects to admin reviews index" do
        get :show, params: {id: -1}
        expect(response).to redirect_to(admin_reviews_path)
      end

      it "sets danger flash message" do
        get :show, params: {id: -1}
        expect(flash[:danger]).to eq(I18n.t("admin.reviews.not_found"))
      end
    end
  end

  describe "PATCH #update" do
    let(:review) {create(:review)}

    context "with valid parameters" do
      let(:valid_params) do
        {
          id: review.id,
          review: {review_status: "approved"}
        }
      end

      before do
        patch :update, params: valid_params
      end

      it "updates the review status" do
        review.reload
        expect(review.review_status).to eq("approved")
      end

      it "sets the approved_by to current user" do
        review.reload
        expect(review.approved_by).to eq(admin)
      end

      it "redirects to the review show page" do
        expect(response).to redirect_to(admin_review_path(review))
      end

      it "sets success flash message" do
        expect(flash[:success]).to eq(I18n.t("admin.reviews.update.success"))
      end
    end

    context "with update failure" do
      before do
        allow_any_instance_of(Review).to receive(:update).and_return(false)
        patch :update, params: {id: review.id, review: {review_status: "approved"}}
      end

      it "does not update the review" do
        review.reload
        expect(review.review_status).to eq("pending")
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash message" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.reviews.update.error"))
      end
    end

    context "with invalid review id" do
      it "redirects to admin reviews index" do
        patch :update, params: {id: -1, review: {review_status: "approved"}}
        expect(response).to redirect_to(admin_reviews_path)
      end

      it "sets danger flash message" do
        patch :update, params: {id: -1, review: {review_status: "approved"}}
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "private methods" do
    describe "#load_reviews" do
      it "loads reviews with preloaded associations" do
        create_list(:review, 3)
        get :index
        expect(assigns(:reviews)).to be_present
      end
    end

    describe "#load_review_by_id" do
      context "when review exists" do
        it "loads the review" do
          get :show, params: {id: review.id}
          expect(assigns(:review)).to eq(review)
        end
      end

      context "when review does not exist" do
        it "redirects and sets flash message" do
          get :show, params: {id: -1}
          expect(response).to redirect_to(admin_reviews_path)
          expect(flash[:danger]).to eq(I18n.t("admin.reviews.not_found"))
        end
      end
    end

    describe "#review_params" do
      let(:params) do
        ActionController::Parameters.new(
          review: {review_status: "approved", rating: 5, comment: "test"}
        )
      end

      before {controller.params = params}
      let(:permitted_params) {controller.send(:review_params)}

      context "when extra params provided" do
        it "permits review_status" do
          expect(permitted_params.keys).to include("review_status")
        end

        it "does not permit rating" do
          expect(permitted_params.keys).not_to include("rating")
        end

        it "does not permit comment" do
          expect(permitted_params.keys).not_to include("comment")
        end
      end
    end
  end
end
