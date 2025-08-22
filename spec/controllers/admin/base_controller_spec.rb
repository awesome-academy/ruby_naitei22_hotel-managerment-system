# spec/controllers/admin/base_controller_spec.rb
require "rails_helper"

RSpec.describe Admin::BaseController, type: :controller do
  include AuthHelpers

  let(:admin) {create(:user, :admin)}
  let(:user) {create(:user)}

  controller(Admin::BaseController) do
    def index
      render plain: "ok"
    end
  end

  describe "GET #index (authenticate_admin!)" do
    context "when logged in as admin" do
      before do
        log_in admin
        get :index
      end

      it "allows access" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when logged in as regular user" do
      before do
        log_in user
        get :index
      end

      it "redirects to root_path" do
        expect(response).to redirect_to(root_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.base.unauthorized_access"))
      end
    end

    context "when not logged in" do
      before do
        log_out
        get :index
      end

      it "redirects to root_path" do
        expect(response).to redirect_to(root_path)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.base.unauthorized_access"))
      end
    end
  end
end
