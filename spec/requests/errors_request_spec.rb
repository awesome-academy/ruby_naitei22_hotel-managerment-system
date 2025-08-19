require 'rails_helper'

RSpec.describe "Errors", type: :request do

  describe "GET /unauthorized" do
    it "returns http success" do
      get "/errors/unauthorized"
      expect(response).to have_http_status(:success)
    end
  end

end
