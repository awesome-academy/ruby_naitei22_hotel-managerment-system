class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :status_changed_by, class_name: User.name, optional: true
  has_many :requests, dependent: :destroy

  enum status: {
    draft: 0,
    pending: 1,
    confirmed: 2,
    declined: 3,
    cancelled: 4,
    completed: 5
  }, _prefix: true

  ASSOCIATIONS_PRELOAD = [:user,
  {requests: {room_availabilities: :room}}].freeze

  scope :by_booking_id, -> {order(id: :desc)}

  scope :with_total_guests, (lambda do
    joins(<<~SQL)
      JOIN (
        SELECT booking_id, SUM(number_of_guests) AS total_guests
        FROM requests
        GROUP BY booking_id
      ) r ON r.booking_id = bookings.id
    SQL
      .select("bookings.*, r.total_guests AS number_of_guests")
  end)

  scope :with_total_price, (lambda do
    joins(requests: :room_availabilities)
      .select("bookings.*, SUM(room_availabilities.price) AS total_price")
      .group("bookings.id")
  end)

  def self.ransackable_attributes _auth_object = nil
    %w(booking_code status)
  end

  def self.ransackable_associations _auth_object = nil
    %w(user)
  end
end
