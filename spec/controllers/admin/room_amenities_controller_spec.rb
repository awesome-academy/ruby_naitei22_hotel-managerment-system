require "rails_helper"

RSpec.describe Admin::AmenitiesController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  let!(:amenity1) { create(:amenity, name: "Air Conditioning", description: "Cool and fresh air system") }
  let!(:amenity2) { create(:amenity, name: "Garage", description: "Spacious underground garage") }
  let!(:amenity3) { create(:amenity, name: "Jacuzzi", description: "Luxury hot water jacuzzi") }

  describe "GET #index" do
    context "without params" do
      before { get :index }

      it "assigns all amenities" do
        expect(assigns(:amenities)).to match_array([amenity1, amenity2, amenity3])
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end
    end

    context "with query param name" do
      it "filters amenities by name" do
        get :index, params: { q: { name_cont: "Air Conditioning" } }
        expect(assigns(:amenities)).to match_array([amenity1])
      end
    end

    context "with query param description" do
      it "filters amenities by description" do
        get :index, params: { q: { description_cont: "Luxury" } }
        expect(assigns(:amenities)).to match_array([amenity3])
      end
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns a new amenity" do
      expect(assigns(:amenity)).to be_a_new(Amenity)
    end

    it "renders the new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) { { amenity: attributes_for(:amenity, name: "Fitness Center", description: "Modern training equipment") } }

      it "creates a new amenity" do
        expect { post :create, params: valid_params }.to change(Amenity, :count).by(1)
      end

      it "assigns correct name" do
        post :create, params: valid_params
        expect(Amenity.last.name).to eq "Fitness Center"
      end

      it "assigns correct description" do
        post :create, params: valid_params
        expect(Amenity.last.description).to eq "Modern training equipment"
      end

      it "sets a success flash" do
        post :create, params: valid_params
        expect(flash[:success]).to eq(I18n.t("admin.amenities.create.success_message"))
      end

      it "redirects to index" do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_amenities_path)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { amenity: { name: "", description: "Just text" } } }

      before { post :create, params: invalid_params }

      it "does not create a new amenity" do
        expect { post :create, params: invalid_params }.not_to change(Amenity, :count)
      end

      it "renders new template" do
        expect(response).to render_template(:new)
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.amenities.create.error_message"))
      end
    end

    context "with unauthorized params" do
      let(:unauthorized_params) { { amenity: { name: "Sauna", description: "Relaxing steam sauna", hacked: "xxx" } } }

      it "creates a new amenity ignoring unauthorized param" do
        expect { post :create, params: unauthorized_params }.to change(Amenity, :count).by(1)
        a = Amenity.last
        expect(a).not_to respond_to(:hacked)
      end
    end
  end

  describe "GET #edit" do
    context "when amenity exists" do
      before { get :edit, params: { id: amenity1.id } }

      it "assigns the amenity" do
        expect(assigns(:amenity)).to eq(amenity1)
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end
    end

    context "when amenity does not exist" do
      before { get :edit, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_amenities_path)
      end

      it "sets a flash message" do
        expect(flash[:warning]).to eq(I18n.t("admin.amenities.load_amenity.not_found"))
      end
    end
  end

  describe "PATCH #update" do
    let(:new_name) { { name: "Smart AC" } }
    let(:new_description) { { description: "Energy-saving cooling system" } }

    context "with valid params" do
      it "updates the name" do
        patch :update, params: { id: amenity1.id, amenity: new_name }
        amenity1.reload
        expect(amenity1.name).to eq "Smart AC"
      end

      it "updates the description" do
        patch :update, params: { id: amenity1.id, amenity: new_description }
        amenity1.reload
        expect(amenity1.description).to eq "Energy-saving cooling system"
      end

      it "sets success flash" do
        patch :update, params: { id: amenity1.id, amenity: { name: "Mini Bar", description: "Room bar service" } }
        expect(flash[:success]).to eq(I18n.t("admin.amenities.update.success_message"))
      end

      it "redirects to index" do
        patch :update, params: { id: amenity1.id, amenity: { name: "Mini Bar", description: "Room bar service" } }
        expect(response).to redirect_to(admin_amenities_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { name: nil } }

      before { patch :update, params: { id: amenity1.id, amenity: invalid_attributes } }

      it "does not update the amenity" do
        amenity1.reload
        expect(amenity1.name).not_to be_nil
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets danger flash" do
        expect(flash.now[:danger]).to eq(I18n.t("admin.amenities.update.error_message"))
      end
    end

    context "when amenity does not exist" do
      before { patch :update, params: { id: -1, amenity: { name: "Does not exist" } } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_amenities_path)
      end

      it "sets not found flash" do
        expect(flash[:warning]).to eq(I18n.t("admin.amenities.load_amenity.not_found"))
      end
    end

    context "with unauthorized params" do
      let(:unauthorized_params) { { id: amenity1.id, amenity: { name: "Balcony", description: "Private balcony with view", hacked: "xxx" } } }

      it "updates the name" do
        patch :update, params: unauthorized_params
        amenity1.reload
        expect(amenity1.name).to eq "Balcony"
      end

      it "updates the description" do
        patch :update, params: unauthorized_params
        amenity1.reload
        expect(amenity1.description).to eq "Private balcony with view"
      end

      it "does not add unauthorized attributes" do
        patch :update, params: unauthorized_params
        amenity1.reload
        expect(amenity1).not_to respond_to(:hacked)
      end

      it "sets success flash" do
        patch :update, params: unauthorized_params
        expect(flash[:success]).to eq(I18n.t("admin.amenities.update.success_message"))
      end

      it "redirects to index" do
        patch :update, params: unauthorized_params
        expect(response).to redirect_to(admin_amenities_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when destroy is successful" do
      it "destroys the amenity" do
        expect { delete :destroy, params: { id: amenity1.id } }.to change(Amenity, :count).by(-1)
      end

      it "sets success flash" do
        delete :destroy, params: { id: amenity2.id }
        expect(flash[:success]).to eq(I18n.t("admin.amenities.destroy.success_message"))
      end

      it "redirects to index" do
        delete :destroy, params: { id: amenity2.id }
        expect(response).to redirect_to(admin_amenities_path)
      end
    end

    context "when destroy fails due to model error" do
      before do
        allow_any_instance_of(Amenity).to receive(:destroy).and_return(false)
        allow_any_instance_of(Amenity).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("destroy error")
        delete :destroy, params: { id: amenity3.id }
      end

      it "does not delete the amenity" do
        expect(Amenity.exists?(amenity3.id)).to be_truthy
      end

      it "sets error flash" do
        expect(flash[:error]).to eq("destroy error")
      end

      it "redirects to index" do
        expect(response).to redirect_to(admin_amenities_path)
      end
    end

    context "when amenity does not exist" do
      before { delete :destroy, params: { id: -1 } }

      it "redirects to index" do
        expect(response).to redirect_to(admin_amenities_path)
      end

      it "sets not found flash" do
        expect(flash[:warning]).to eq(I18n.t("admin.amenities.load_amenity.not_found"))
      end
    end
  end

  describe "before_action load_amenity" do
    context "when amenity exists" do
      it "assigns @amenity" do
        get :edit, params: { id: amenity1.id }
        expect(assigns(:amenity)).to eq(amenity1)
      end
    end

    context "when amenity does not exist" do
      before { get :edit, params: { id: -1 } }

      it "sets flash warning" do
        expect(flash[:warning]).to eq(I18n.t("admin.amenities.load_amenity.not_found"))
      end

      it "redirects to index" do
        expect(response).to redirect_to(admin_amenities_path)
      end
    end
  end
end
