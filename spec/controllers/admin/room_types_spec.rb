require "rails_helper"

RSpec.describe Admin::RoomTypesController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  # Test data
  let!(:room_type1) { create(:room_type, name: "Single", description: "Single desc") }
  let!(:room_type2) { create(:room_type, name: "Double", description: "Double desc") }
  let!(:room_type3) { create(:room_type, name: "Suite", description: "Suite luxury") }

  # Index
  describe "GET #index" do
    context "without params" do
      before { get :index }

      it "assigns all room_types" do
        expect(assigns(:room_types)).to match_array([room_type1, room_type2, room_type3])
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end
    end

    context "with query param name" do
      it "filters room_types by name" do
        get :index, params: { q: { name_cont: "Sing" } }
        expect(assigns(:room_types)).to match_array([room_type1])
      end
    end

    context "with query param description" do
      it "filters room_types by description" do
        get :index, params: { q: { description_cont: "luxury" } }
        expect(assigns(:room_types)).to match_array([room_type3])
      end
    end
  end

  # Test cho action new
  describe "GET #new" do
    before { get :new }

    it "assigns a new room_type" do
      expect(assigns(:room_type)).to be_a_new(RoomType)
    end
    it "renders the new template" do
      expect(response).to render_template(:new)
    end
  end

  # Create
  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) { { room_type: attributes_for(:room_type, name: "Deluxe", description: "Deluxe desc") } }

      it "creates a new room_type" do
        expect { post :create, params: valid_params }.to change(RoomType, :count).by(1)
      end

      it "assigns correct name to room_type" do
        post :create, params: valid_params
        rt = RoomType.last
        expect(rt.name).to eq "Deluxe"
      end

      it "assigns correct description to room_type" do
        post :create, params: valid_params
        rt = RoomType.last
        expect(rt.description).to eq "Deluxe desc"
      end

      it "sets a success flash" do
        post :create, params: valid_params
        expect(flash[:success]).to eq(I18n.t("admin.room_types.create.success_message"))
      end

      it "redirects to index" do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_room_types_path)
      end
    end

    context "with invalid params" do
      let(:invalid_params_blank_name) { { room_type: { name: "", description: "Some desc" } } }

      before { post :create, params: invalid_params_blank_name }

      it "does not create a new room_type" do
        expect { post :create, params: invalid_params_blank_name }.not_to change(RoomType, :count)
      end

      it "renders new template" do
        expect(response).to render_template(:new)
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.room_types.create.error_message"))
      end
    end

    context "with unauthorized params" do
      let(:unauthorized_params) { { room_type: { name: "VIP", description: "VIP desc", hacked: "xxx" } } }

      it "creates a new room_type ignoring unauthorized param" do
        expect { post :create, params: unauthorized_params }.to change(RoomType, :count).by(1)
        rt = RoomType.last
        expect(rt).not_to respond_to(:hacked)
      end
    end
  end

  # Edit
  describe "GET #edit" do
    context "when room_type exists" do
      before { get :edit, params: { id: room_type1.id } }

      it "assigns the requested room_type" do
        expect(assigns(:room_type)).to eq(room_type1)
      end
      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end
    end

    context "when room_type does not exist" do
      before { get :edit, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_types_path)
      end
      it "sets a flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_types.load_room_type.not_found"))
      end
    end
  end

  # Update
  describe "PATCH #update" do
    let(:new_name) { { name: "Updated Single" } }
    let(:new_description) { { description: "Updated description" } }

    context "with valid params" do
      it "updates the name" do
        patch :update, params: { id: room_type1.id, room_type: new_name }
        room_type1.reload
        expect(room_type1.name).to eq "Updated Single"
      end

      it "updates the description" do
        patch :update, params: { id: room_type1.id, room_type: new_description }
        room_type1.reload
        expect(room_type1.description).to eq "Updated description"
      end

      it "sets success flash" do
        patch :update, params: { id: room_type1.id, room_type: { name: "New", description: "New desc" } }
        expect(flash[:success]).to eq(I18n.t("admin.room_types.update.success_message"))
      end

      it "redirects to index" do
        patch :update, params: { id: room_type1.id, room_type: { name: "New", description: "New desc" } }
        expect(response).to redirect_to(admin_room_types_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { name: nil } }

      before { patch :update, params: { id: room_type1.id, room_type: invalid_attributes } }

      it "does not update the room_type" do
        room_type1.reload
        expect(room_type1.name).not_to be_nil
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.room_types.update.error_message"))
      end
    end

    context "when room_type does not exist" do
      before { patch :update, params: { id: -1, room_type: { name: "X" } } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_types_path)
      end
      it "sets flash not found" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_types.load_room_type.not_found"))
      end
    end

    context "with unauthorized params" do
      let(:unauthorized_params) do
        { id: room_type1.id, room_type: { name: "Allowed", description: "Allowed desc", hacked: "xxx" } }
      end

      it "updates the name in the database" do
        patch :update, params: unauthorized_params
        room_type1.reload
        expect(room_type1.name).to eq("Allowed")
      end

      it "updates the description in the database" do
        patch :update, params: unauthorized_params
        room_type1.reload
        expect(room_type1.description).to eq("Allowed desc")
      end

      it "does not add unauthorized attributes" do
        patch :update, params: unauthorized_params
        room_type1.reload
        expect(room_type1).not_to respond_to(:hacked)
      end

      it "sets a success flash message" do
        patch :update, params: unauthorized_params
        expect(flash[:success]).to eq(I18n.t("admin.room_types.update.success_message"))
      end

      it "redirects to the index page" do
        patch :update, params: unauthorized_params
        expect(response).to redirect_to(admin_room_types_path)
      end
    end
  end

  # Test cho action destroy
  describe "DELETE #destroy" do
    context "when destroy is successful" do
      it "destroys the requested room_type" do
        expect { delete :destroy, params: { id: room_type1.id } }.to change(RoomType, :count).by(-1)
      end

      it "sets a success flash message" do
        delete :destroy, params: { id: room_type2.id }
        expect(flash[:success]).to eq(I18n.t("admin.room_types.destroy.success_message"))
      end

      it "redirects to the index page" do
        delete :destroy, params: { id: room_type2.id }
        expect(response).to redirect_to(admin_room_types_path)
      end
    end

    context "when destroy fails due to model error" do
      before do
        allow_any_instance_of(RoomType).to receive(:destroy).and_return(false)
        allow_any_instance_of(RoomType).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("destroy error")
        delete :destroy, params: { id: room_type3.id }
      end

      it "does not delete the room_type" do
        expect(RoomType.exists?(room_type3.id)).to be_truthy
      end

      it "sets a danger flash message" do
        expect(flash[:danger]).to eq("destroy error")
      end

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_types_path)
      end
    end

    context "when room_type does not exist" do
      before { delete :destroy, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_room_types_path)
      end
      it "sets not found flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_types.load_room_type.not_found"))
      end
    end
  end

  # before_action :load_room_type (edit/update/destroy)
  describe "before_action load_room_type" do
    context "when room_type exists" do
      it "assigns @room_type" do
        get :edit, params: { id: room_type1.id }
        expect(assigns(:room_type)).to eq(room_type1)
      end
    end

    context "when room_type does not exist" do
      before { get :edit, params: { id: -99 } }

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_types.load_room_type.not_found"))
      end
      it "redirects to index" do
        expect(response).to redirect_to(admin_room_types_path)
      end
    end
  end
end
