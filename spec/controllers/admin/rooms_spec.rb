require "rails_helper"

RSpec.describe Admin::RoomsController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  # Test data
  let!(:room_type1) { create(:room_type, name: "Type A") }
  let!(:room_type2) { create(:room_type, name: "Type B") }
  let!(:room1) { create(:room, room_type: room_type1, room_number: "A101") }
  let!(:room2) { create(:room, room_type: room_type1, room_number: "A202") }
  let!(:room3) { create(:room, room_type: room_type2, room_number: "B303") }

  describe "GET #index" do
    context "without params" do
      before { get :index }

      it "assigns all rooms" do
        expect(assigns(:rooms)).to match_array([room1, room2, room3])
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end
    end

    context "with query param room_number" do
      it "filters rooms by room_number" do
        get :index, params: { q: { room_number_cont: "A10" } }
        expect(assigns(:rooms)).to match_array([room1])
      end
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns a new room" do
      expect(assigns(:room)).to be_a_new(Room)
    end

    it "renders the new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    context "when room exists" do
      before { get :edit, params: { id: room1.id } }

      it "assigns the requested room" do
        expect(assigns(:room)).to eq(room1)
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end
    end

    context "when room does not exist" do
      before { get :edit, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_rooms_path)
      end

      it "sets a flash message" do
        expect(flash[:danger]).to eq(I18n.t("admin.rooms.load_room.not_found"))
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        room: attributes_for(:room, room_number: "C404").merge(room_type_id: room_type1.id)
      }
    end

    context "with valid params" do
      it "creates a new room" do
        expect { post :create, params: valid_params }.to change(Room, :count).by(1)
      end

      it "sets success flash" do
        post :create, params: valid_params
        expect(flash[:success]).to eq(I18n.t("admin.rooms.create.success"))
      end

      it "redirects to show" do
        post :create, params: valid_params
        room = Room.last
        expect(response).to redirect_to(admin_room_path(room))
      end
    end

    context "with invalid params (blank room_number)" do
      let(:invalid_params) do
        {
          room: {
            room_number: "",
            room_type_id: room_type1.id,
            capacity: 2,
            description: "Desc",
            price_from_date: Date.today,
            price_to_date: Date.today + 10.days,
            price: 100
          }
        }
      end

      before { post :create, params: invalid_params }

      it "does not create a new room" do
        expect(Room.where(room_number: "").count).to eq(0)
      end

      it "renders new template" do
        expect(response).to render_template(:new)
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.rooms.create.failure"))
      end
    end

    context "with unauthorized params" do
      let(:unauthorized_params) do
        { room: attributes_for(:room, room_number: "D505", hacked: "xxx").merge(room_type_id: room_type1.id) }
      end

      it "creates a new room ignoring unauthorized param" do
        expect { post :create, params: unauthorized_params }.to change(Room, :count).by(1)
        room = Room.last
        expect(room).not_to respond_to(:hacked)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates the description" do
        patch :update, params: { id: room1.id, room: { description: "Updated desc" } }
        room1.reload
        expect(room1.description).to eq("Updated desc")
      end

      it "sets success flash" do
        patch :update, params: { id: room1.id, room: { description: "Updated desc" } }
        expect(flash[:success]).to eq(I18n.t("admin.rooms.update.success"))
      end

      it "redirects to show" do
        patch :update, params: { id: room1.id, room: { description: "Updated desc" } }
        expect(response).to redirect_to(admin_room_path(room1))
      end
    end

    context "with invalid params" do
      before { patch :update, params: { id: room1.id, room: { room_number: "" } } }

      it "does not update the room" do
        room1.reload
        expect(room1.room_number).not_to eq("")
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable_entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.rooms.update.failure"))
      end
    end

    context "when room does not exist" do
      before { patch :update, params: { id: -1, room: { description: "X" } } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_rooms_path)
      end

      it "sets not found flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.rooms.load_room.not_found"))
      end
    end

    context "with unauthorized params" do
      let(:unauthorized_params) do
        { id: room1.id, room: { description: "Allowed", hacked: "xxx" } }
      end

      it "updates the description" do
        patch :update, params: unauthorized_params
        room1.reload
        expect(room1.description).to eq("Allowed")
      end

      it "does not add unauthorized attribute" do
        patch :update, params: unauthorized_params
        expect(room1).not_to respond_to(:hacked)
      end

      it "sets success flash" do
        patch :update, params: unauthorized_params
        expect(flash[:success]).to eq(I18n.t("admin.rooms.update.success"))
      end

      it "redirects to show" do
        patch :update, params: unauthorized_params
        expect(response).to redirect_to(admin_room_path(room1))
      end
    end
  end

  describe "GET #show" do
    context "when room does not exist" do
      before { get :show, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_rooms_path)
      end

      it "sets not found flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.rooms.load_room.not_found"))
      end
    end
  end

  describe "DELETE #destroy" do
    context "when destroy is successful" do
      it "destroys the requested room" do
        expect { delete :destroy, params: { id: room2.id } }.to change(Room, :count).by(-1)
      end

      it "sets success flash" do
        delete :destroy, params: { id: room2.id }
        expect(flash[:success]).to eq(I18n.t("admin.rooms.destroy.success"))
      end

      it "redirects to index" do
        delete :destroy, params: { id: room2.id }
        expect(response).to redirect_to(admin_rooms_path)
      end
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Room).to receive(:destroy).and_return(false)
        allow_any_instance_of(Room).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("destroy error")
        delete :destroy, params: { id: room3.id }
      end

      it "does not delete the room" do
        expect(Room.exists?(room3.id)).to be_truthy
      end

      it "sets danger flash" do
        expect(flash[:danger]).to eq("destroy error")
      end

      it "redirects to index" do
        expect(response).to redirect_to(admin_rooms_path)
      end
    end

    context "when room does not exist" do
      before { delete :destroy, params: { id: -99 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_rooms_path)
      end

      it "sets not found flash" do
        expect(flash[:danger]).to eq(I18n.t("admin.rooms.load_room.not_found"))
      end
    end
  end

  describe "DELETE #remove_image" do
    context "when image exists" do
      it "purges the image and redirects back" do
        image_double = instance_double(ActiveStorage::Attachment)
        allow(ActiveStorage::Attachment).to receive(:find_by).and_return(image_double)
        expect(image_double).to receive(:purge_later)
        request.env["HTTP_REFERER"] = admin_rooms_path
        delete :remove_image, params: { id: room1.id, image_id: 123 }
        expect(response).to redirect_to(admin_rooms_path)
      end
    end

    context "when image does not exist" do
      it "redirects back without error" do
        allow(ActiveStorage::Attachment).to receive(:find_by).and_return(nil)
        request.env["HTTP_REFERER"] = admin_rooms_path
        delete :remove_image, params: { id: room1.id, image_id: 999 }
        expect(response).to redirect_to(admin_rooms_path)
      end
    end
  end

  describe "before_action load_room" do
    context "when room exists" do
      it "assigns @room" do
        get :edit, params: { id: room1.id }
        expect(assigns(:room)).to eq(room1)
      end
    end

    context "when room does not exist" do
      before { get :edit, params: { id: -123 } }

      it "sets flash danger" do
        expect(flash[:danger]).to eq(I18n.t("admin.rooms.load_room.not_found"))
      end

      it "redirects to index" do
        expect(response).to redirect_to(admin_rooms_path)
      end
    end
  end
end
