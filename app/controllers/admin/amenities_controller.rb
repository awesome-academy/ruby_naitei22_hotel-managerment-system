class Admin::AmenitiesController < Admin::BaseController
  before_action :load_amenity, only: %i(edit update destroy)

  # GET /admin/amenities
  def index
    @q = Amenity.ransack(params[:q])
    scope = @q.result(distinct: true)
    @pagy, @amenities = pagy(scope, items: Settings.default.digit_10,
                                   limit: Settings.default.digit_10)
  end

  # GET /admin/amenities/new
  def new
    @amenity = Amenity.new
  end

  # POST /admin/amenities
  def create
    @amenity = Amenity.new amenity_params
    if @amenity.save
      handle_successful_creation
    else
      handle_failed_creation
    end
  end

  # GET /admin/amenities/:id/edit
  def edit; end

  # PATCH/PUT /admin/amenities/:id
  def update
    if @amenity.update amenity_params
      handle_successful_update
    else
      handle_failed_update
    end
  end

  # DELETE /admin/amenities/:id
  def destroy
    if @amenity.destroy
      flash[:success] = t(".success_message")
    else
      flash[:error] = t(".error_message")
    end
    redirect_to admin_amenities_path
  end

  private

  def amenity_params
    params.require(:amenity).permit Amenity::AMENITY_PARAMS
  end

  def load_amenity
    @amenity = Amenity.find_by(id: params[:id])
    return if @amenity

    flash[:warning] = t("admin.amenities.load_amenity.not_found")
    redirect_to admin_amenities_path
  end

  def handle_successful_creation
    flash[:success] = t(".success_message")
    redirect_to admin_amenities_path
  end

  def handle_failed_creation
    flash.now[:danger] = t(".error_message")
    render :new, status: :unprocessable_entity
  end

  def handle_successful_update
    flash[:success] = t(".success_message")
    redirect_to admin_amenities_path
  end

  def handle_failed_update
    flash.now[:danger] = t(".error_message")
    render :edit, status: :unprocessable_entity
  end
end
