class ReviewsController < ApplicationController
  before_action :set_user

  def index
    @reviews = @user.reviews
  end

  def create
    @review = @user.reviews.new(review_params)

    if @review.save
      flash[:success] = t(".success")
      redirect_to user_bookings_path(@user)
    else
      flash.now[:error] = t(".error")
    end
  end

  def destroy
    @review = @user.reviews.find_by(id: params[:id])

    flash[@review&.destroy ? :success : :error] =
      t(@review ? ".success" : ".error")

    redirect_to after_destroy_path
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment, :request_id)
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
