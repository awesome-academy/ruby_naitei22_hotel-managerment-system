require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:booking) { create(:booking, user: user) }
  let(:request) { create(:request, status: :pending, booking: booking) }
  let!(:review) { create(:review, user: user, request: request) }

  before do
    sign_in user
  end

  describe "GET #show" do
    context "when user exists" do
      it "assigns @user" do
        get :show, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end

      it "assigns @reviews" do
        get :show, params: { id: user.id }
        expect(assigns(:reviews)).to include(review)
      end
    end

    context "when user does not exist" do
      it "raises ActiveRecord::RecordNotFound (cancancan behavior)" do
        expect {
          get :show, params: { id: -1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET #edit" do
    before{get :edit, params: { id: user.id }}
    it "assigns the requested user" do
      expect(assigns(:user)).to eq(user)
    end

    it "renders edit" do
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
    context "when update success" do
      before{patch :update, params: { id: user.id, user: { name: "New Name" } }}
      it "updates user" do
        expect(response).to render_template(:edit)
      end

      it "renders edit" do
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when update fails" do
      before do
        put :update, params: { id: user.id, user: { name: "" } }
      end

      it "sets a danger flash" do
        expect(flash[:danger]).to be_present
      end

      it "re-renders edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        expect(response.status).to eq(422)
      end
    end
  end
end
