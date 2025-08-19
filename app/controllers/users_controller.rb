class UsersController < ApplicationController
  load_and_authorize_resource

  # GET /users/:id
  def show
    @reviews = @user.reviews.includes(request: :booking)
  end

  # GET /users/:id/edit
  def edit; end

  # PUT /users/:id
  def update
    if @user.update(user_params)
      flash[:success] = t(".success")
      render :edit, status: :see_other
    else
      flash[:danger] = t(".failure")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(User::USER_PERMIT)
  end
end
