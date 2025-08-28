require "rails_helper"

RSpec.describe RequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:booking) { create(:booking, user: user) }
  let!(:request_record) { create(:request, booking: booking) }

  before { sign_in user }

  describe "DELETE #destroy" do
    context "when request does not exist" do
      before { delete :destroy, params: { id: -1 } }

      it "sets warning flash" do
        expect(flash[:warning]).to eq(I18n.t("requests.not_found"))
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH #cancel" do
    context "when request is not pending" do
      let!(:confirmed_request) { create(:request, booking: booking, status: :confirmed) }

      it "does not change status" do
        expect do
          patch :cancel, params: { user_id: user.id, id: confirmed_request.id }
        end.not_to change { confirmed_request.reload.status }
      end

      it "sets alert flash" do
        patch :cancel, params: { user_id: user.id, id: confirmed_request.id }
        expect(flash[:alert]).to eq(I18n.t("requests.cancel.alert"))
      end
    end

    context "when request not found" do
      before { patch :cancel, params: { user_id: user.id, id: -1 } }

      it "sets warning flash" do
        expect(flash[:warning]).to eq(I18n.t("requests.not_found"))
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
