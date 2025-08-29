require "rails_helper"

RSpec.describe Admin::RoomTypesController, type: :controller do
  let(:admin) { create(:user, role: :admin) }
  let!(:room_type) { create(:room_type) }

  before { sign_in admin }

  describe "GET #index" do
    before { get :index }

    it "returns success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns @room_types" do
      expect(assigns(:room_types)).to include(room_type)
    end
  end

  describe "GET #new" do
    before { get :new }

    it "returns success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns a new RoomType" do
      expect(assigns(:room_type)).to be_a_new(RoomType)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) { { room_type: { name: "Deluxe", description: "Nice room" } } }

      it "creates a new room type" do
        expect {
          post :create, params: valid_params
        }.to change(RoomType, :count).by(1)
      end

      it "redirects to room types index" do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_room_types_path)
      end

      it "sets success flash" do
        post :create, params: valid_params
        expect(flash[:success]).to eq(I18n.t("admin.room_types.create.success_message"))
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { room_type: { name: "" } } }

      it "does not create a room type" do
        expect {
          post :create, params: invalid_params
        }.not_to change(RoomType, :count)
      end

      it "renders new template with status 422" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets error flash" do
        post :create, params: invalid_params
        expect(flash.now[:danger]).to eq(I18n.t("admin.room_types.create.error_message"))
      end
    end
  end

  describe "GET #edit" do
    before { get :edit, params: { id: room_type.id } }

    context "found" do
      it "returns success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns @room_type" do
        expect(assigns(:room_type)).to eq(room_type)
      end
    end

    context "not found" do
      let(:invalid_id) { 0 }
      before { get :edit, params: { id: invalid_id } }

      it "redirects to room types index" do
        expect(response).to redirect_to(admin_room_types_path)
      end

      it "sets danger flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.room_types.load_room_type.not_found"))
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:valid_params) { { id: room_type.id, room_type: { name: "Updated Name" } } }

      it "updates the room type" do
        patch :update, params: valid_params
        room_type.reload
        expect(room_type.name).to eq("Updated Name")
      end

      it "redirects to room types index" do
        patch :update, params: valid_params
        expect(response).to redirect_to(admin_room_types_path)
      end

      it "sets success flash" do
        patch :update, params: valid_params
        expect(flash[:success]).to eq(I18n.t("admin.room_types.update.success_message"))
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { id: room_type.id, room_type: { name: "" } } }

      it "does not update the room type" do
        patch :update, params: invalid_params
        room_type.reload
        expect(room_type.name).not_to eq("")
      end

      it "renders edit template with status 422" do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets error flash" do
        patch :update, params: invalid_params
        expect(flash.now[:danger]).to eq(I18n.t("admin.room_types.update.error_message"))
      end
    end
  end

  describe "DELETE #destroy" do
    context "when destroy succeeds" do
      it "deletes the room type" do
        expect {
          delete :destroy, params: { id: room_type.id }
        }.to change(RoomType, :count).by(-1)
      end

      it "redirects to room types index" do
        delete :destroy, params: { id: room_type.id }
        expect(response).to redirect_to(admin_room_types_path)
      end

      it "sets success flash" do
        delete :destroy, params: { id: room_type.id }
        expect(flash[:success]).to eq(I18n.t("admin.room_types.destroy.success_message"))
      end
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(RoomType).to receive(:destroy).and_return(false)
        allow_any_instance_of(RoomType).to receive_message_chain(:errors, :full_messages).and_return(["Cannot delete"])
      end

      it "does not delete the room type" do
        expect {
          delete :destroy, params: { id: room_type.id }
        }.not_to change(RoomType, :count)
      end

      it "redirects to room types index with error flash" do
        delete :destroy, params: { id: room_type.id }
        expect(flash[:danger]).to eq("Cannot delete")
        expect(response).to redirect_to(admin_room_types_path)
      end
    end
  end
end
