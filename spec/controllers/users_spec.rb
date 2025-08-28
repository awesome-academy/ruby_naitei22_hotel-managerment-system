require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #show" do
    context "when user exists" do
      before { get :show, params: { id: user.id } }

      it "assigns the requested user" do
        expect(assigns(:user)).to eq(user)
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when user does not exist" do
      before { get :show, params: { id: -1 } }

      it "redirects to root" do
        expect(response).to redirect_to(root_path)
      end

      it "sets warning flash" do
        expect(flash[:warning]).to eq(I18n.t("users.not_found"))
      end
    end
  end

  describe "GET #edit" do
    before { get :edit, params: { id: user.id } }

    it "assigns the user" do
      expect(assigns(:user)).to eq(user)
    end

    it "renders the edit template" do
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_name) { "Updated Name" }

      before do
        put :update, params: { id: user.id, user: { name: new_name } }
        user.reload
      end

      it "updates the user" do
        expect(user.name).to eq(new_name)
      end

      it "sets success flash" do
        expect(flash[:success]).to eq(I18n.t("users.update.success"))
      end

      it "renders edit with see_other status" do
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:see_other)
      end
    end

    context "with invalid params" do
      before do
        put :update, params: { id: user.id, user: { name: "" } }
      end

      it "does not update the user" do
        expect(user.reload.name).not_to eq("")
      end

      it "sets danger flash" do
        expect(flash[:danger]).to eq(I18n.t("users.update.failure"))
      end

      it "renders edit with unprocessable_entity status" do
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
