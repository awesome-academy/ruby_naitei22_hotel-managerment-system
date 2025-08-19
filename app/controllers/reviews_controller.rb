class ReviewsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource :user

  before_action :set_review, only: :destroy

  # GET (/:locale)/users/:user_id/reviews(.:format)
  def index
    @reviews = @user.reviews
  end

  # POST (/:locale)/users/:user_id/reviews(.:format)
  def create
    @review = @user.reviews.new(review_params)

    if @review.save
      flash[:success] = t(".success")
      redirect_to user_bookings_path(@user)
    else
      flash.now[:error] = t(".error")
    end
  end

  # DELETE (/:locale)/users/:user_id/reviews/:id(.:format)
  def destroy
    if @review&.destroy
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to after_destroy_path
  end

  private

  def set_review
    @review = @user.reviews.find_by(id: params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment, :request_id,
                                   :review_status)
  end

  def after_destroy_path
    referer_path = URI(request.referer || "").path
    if referer_path.include?(user_bookings_path(@user))
      user_bookings_path(@user)
    else
      user_reviews_path(@user)
    end
  end
end
