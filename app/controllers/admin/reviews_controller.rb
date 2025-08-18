class Admin::ReviewsController < Admin::BaseController
  before_action :load_reviews, only: :index
  before_action :load_review_by_id, only: [:show, :update]

  # GET /admin/reviews
  def index; end

  # GET /admin/reviews/:id
  def show; end

  # PATCH /admin/reviews/:id
  def update
    if @review.update(review_status: review_params[:review_status],
                      approved_by: current_user)
      flash[:success] = t(".success")
      redirect_to admin_review_path(@review)
    else
      flash.now[:danger] = t(".error")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def load_reviews
    @q = Review.preload(Review::ASSOCIATIONS_PRELOAD)
               .by_review_id
               .ransack(params[:q])

    scope = @q.result(distinct: true)
    @pagy, @reviews = pagy(scope, items: Settings.default.digit_10,
                                  limit: Settings.default.digit_10)
  end

  def load_review_by_id
    @review = Review.preload(Review::ASSOCIATIONS_PRELOAD)
                    .find_by(id: params[:id])
    return if @review

    flash[:danger] = t(".not_found")
    redirect_to admin_reviews_path
  end

  def review_params
    params.require(:review).permit(:review_status)
  end
end
