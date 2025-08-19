require "rails_helper"

RSpec.describe ChangePasswordsController, type: :controller do
  let(:user) { create(:user, password: "oldpassword", password_confirmation: "oldpassword") }

  before do
    sign_in user
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { user_id: user.id }
      expect(response).to have_http_status(:success)
    end

    it "renders the edit template" do
      get :edit, params: { user_id: user.id }
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    context "with correct current password" do
      before{patch :update, params: { user_id: user.id, user: { current_password: "oldpassword", password: "newpassword", password_confirmation: "newpassword" } }}

      it "updates user's password" do
        expect(user.reload.valid_password?("newpassword")).to be true
      end

      it "sets flash[:success]" do
        expect(flash[:success]).to eq(I18n.t("change_passwords.update.success"))
      end

      it "redirects to edit page" do
        expect(response).to redirect_to(edit_user_change_password_path(user))
      end
    end

    context "with incorrect current password" do
      before {patch :update, params: { user_id: user.id, user: { current_password: "wrongpassword", password: "newpassword", password_confirmation: "newpassword" } }}
      
      it "does not update password" do
        expect(user.reload.valid_password?("oldpassword")).to be true
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to eq(I18n.t("change_passwords.update.wrong_password"))
      end
    end

    context "with invalid new password (confirmation mismatch)" do
      before{patch :update, params: { user_id: user.id, user: { current_password: "oldpassword", password: "newpassword", password_confirmation: "mismatch" } }}
      
      it "does not update the password" do
        expect(user.reload.valid_password?("oldpassword")).to be true
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "sets flash[:danger]" do
        expect(flash[:danger]).to eq(I18n.t("change_passwords.update.wrong_password"))
      end
    end
  end
end
