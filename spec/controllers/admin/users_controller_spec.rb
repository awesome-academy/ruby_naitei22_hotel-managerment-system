require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  let!(:user1) { create(:user, name: "Alice", email: "alice@example.com", phone: "12345") }
  let!(:user2) { create(:user, name: "Bob", email: "bob@example.com", phone: "67890") }
  let!(:user3) { create(:user, name: "Charlie", email: "charlie@example.com", phone: "55555") }

  describe "GET #index" do
    context "without params" do
      before { get :index }

      it "assigns users including created ones" do
        expect(assigns(:users)).to include(user1, user2, user3, admin)
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end
    end

    context "with query param name" do
      it "filters users by name" do
        get :index, params: { q: { name_cont: "Ali" } }
        expect(assigns(:users)).to match_array([user1])
      end
    end

    context "with query param email" do
      it "filters users by email" do
        get :index, params: { q: { email_cont: "bob@" } }
        expect(assigns(:users)).to match_array([user2])
      end
    end

    context "with query param phone" do
      it "filters users by phone" do
        get :index, params: { q: { phone_cont: "555" } }
        expect(assigns(:users)).to match_array([user3])
      end
    end
  end

  describe "GET #show" do
    context "when user exists" do
      before { get :show, params: { id: user1.id } }

      it "assigns the requested user" do
        expect(assigns(:user)).to eq(user1)
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when user does not exist" do
      before { get :show, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_users_path)
      end

      it "sets danger flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.users.show.not_found"))
      end
    end
  end
end
