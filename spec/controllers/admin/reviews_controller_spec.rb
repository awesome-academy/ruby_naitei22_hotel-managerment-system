require "rails_helper"

RSpec.describe Admin::ReviewsController, type: :controller do
  let(:admin) { create(:user, role: :admin) }
  let(:user) { create(:user) }
  let!(:review) { create(:review, user: user, review_status: :pending) }

  before { sign_in admin }

  describe "GET #index" do
    before { get :index }

    it "assigns @reviews" do
      expect(assigns(:reviews)).to include(review)
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    context "when review exists" do
      before { get :show, params: { id: review.id } }

      it "assigns @review" do
        expect(assigns(:review)).to eq(review)
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when review does not exist" do
      before { get :show, params: { id: 0 } }

      it "redirects to reviews index" do
        expect(response).to redirect_to(admin_reviews_path)
      end

      it "sets danger flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.reviews.not_found"))
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      before do
        patch :update, params: { id: review.id, review: { review_status: :approved } }
      end

      it "updates the review" do
        expect(review.reload.review_status).to eq("approved")
      end

      it "sets success flash" do
        expect(flash[:success]).to eq(I18n.t("admin.reviews.update.success"))
      end

      it "redirects to review show" do
        expect(response).to redirect_to(admin_review_path(review))
      end
    end

    context "with invalid params" do
      before do
        allow_any_instance_of(Review).to receive(:update).and_return(false)
        patch :update, params: { id: review.id, review: { review_status: nil } }
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.reviews.update.error"))
      end

      it "renders show template" do
        expect(response).to render_template(:show)
      end
    end
  end
end
