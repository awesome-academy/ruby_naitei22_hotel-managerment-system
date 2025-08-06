# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    else
      can :read, Room
      can :read, Amenity
      can :read, Review
      can :read, RoomType
      can :read, RoomAvailability
      if user.present?
        user_role_user
        user_role_booking
        user_role_request_review
      end
    end
  end

  private

  def user_role_user
    can :read, User, id: user.id
    can :update, User, id: user.id
  end

  def user_role_booking
    can :create, Booking, user_id: user.id
    can :read, Booking, user_id: user.id
    can :update, Booking, user_id: user.id
  end

  def user_role_request_review
    can :create, Request, booking: {user_id: user.id}
    can :read, Request, booking: {user_id: user.id}
    can :update, Request, booking: {user_id: user.id}

    can :create, Review, request: {booking: {user_id: user.id}}
    can :read, Review, request: {booking: {user_id: user.id}}
    can :update, Review, request: {booking: {user_id: user.id}}
  end
end
