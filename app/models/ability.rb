class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new

    if user.role_user?
      define_user_permissions user
    elsif user.role_admin?
      can :manage, :all
      can :access, :admin
    end
  end

  private

  def define_user_permissions user
    can [:read, :update], User, id: user.id

    can [:create, :read, :update, :current_booking, :confirm_booking, :cancel],
        Booking, user_id: user.id
    can :destroy, Booking, user_id: user.id, status: %w(draft)

    can [:destroy, :cancel], Request, booking: {user_id: user.id},
    status: :draft

    can [:create, :read, :destroy], Review,
        request: {booking: {user_id: user.id}}
  end
end
