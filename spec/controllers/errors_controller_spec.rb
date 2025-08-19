require "rails_helper"

RSpec.describe ErrorsController, type: :controller do
  describe "GET #unauthorized" do
    before { get :unauthorized }

    it "returns http unauthorized" do
      expect(response).to have_http_status(:unauthorized)
    end

    it "renders the unauthorized template" do
      expect(response).to render_template(:unauthorized)
    end
  end

  describe "GET #not_found" do
    before{get :not_found, params: { path: "anything" }}

    it "renders not_found" do
      expect(response).to render_template(:not_found)
    end

    it "renders 404" do
      expect(response).to have_http_status(:not_found)
    end
  end
end
