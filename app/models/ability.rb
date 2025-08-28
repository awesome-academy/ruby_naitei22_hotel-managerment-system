# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    @user = user || User.new # guest user

    can :read, Room
    can :read, Amenity
    can :read, Review
    can :read, RoomType
    can :read, RoomAvailability

    if @user.persisted?
      user_role_user
      user_role_booking
      user_role_request
      user_role_review
    elsif @user.role_admin?
      can :manage, :all
      can :access, :admin_panel
    end
  end

  private

  def user_role_user
    can :show, User, id: @user.id
    can :update, User, id: @user.id

    alias_action :edit, :update, to: :change_password
    can :change_password, User, id: @user.id
  end

  def user_role_booking
    can :create, Booking, user: @user
    can :read, Booking, user_id: @user.id
    can :update, Booking, user_id: @user.id
    can :destroy, Booking, user_id: @user.id
    can :current_booking, Booking, user_id: @user.id
    can :confirm_booking, Booking, user_id: @user.id
    can :cancel, Booking, user_id: @user.id
  end

  def user_role_request
    can :create, Request, booking: {user_id: @user.id}
    can :read, Request, booking: {user_id: @user.id}
    can :update, Request, booking: {user_id: @user.id}
    can :destroy, Request, booking: {user_id: @user.id}
    can :cancel, Request, booking: {user_id: @user.id}
  end

  def user_role_review
    can :create, Review, user_id: @user.id
    can :read, Review, user_id: @user.id
    can :update, Review, user_id: @user.id
    can :destroy, Review, user_id: @user.id
  end
end
