class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :status_changed_by, class_name: User.name, optional: true

  has_many :requests, dependent: :destroy
  has_many :room_availability_requests, through: :requests
  has_many :room_availabilities, through: :room_availability_requests
  has_many :rooms, -> {distinct}, through: :room_availabilities

  accepts_nested_attributes_for :requests

  enum status: {
    draft: 0,
    pending: 1,
    confirmed: 2,
    declined: 3,
    cancelled: 4,
    completed: 5
  }, _prefix: true

  ASSOCIATIONS_PRELOAD = [:user,
  {requests: [:guests, {room_availabilities: {room: :room_type}}]}].freeze

  UPDATE_PARAMS = %i(status decline_reason).freeze
  INVALID_STATUSES = %i(draft declined cancelled).freeze

  after_update :cascade_requests_on_confirm,
               if: -> {saved_change_to_status? && status_confirmed?}

  after_update :cascade_requests_on_decline,
               if: -> {saved_change_to_status? && status_declined?}

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

  scope :with_total_requests, (lambda do
    joins(<<~SQL)
      JOIN (
        SELECT booking_id, COUNT(requests.id) AS total_requests
        FROM requests
        GROUP BY booking_id
      ) re ON re.booking_id = bookings.id
    SQL
      .select("bookings.*, re.total_requests AS total_requests")
  end)

  def self.ransackable_attributes _auth_object = nil
    %w(booking_code status)
  end

  def self.ransackable_associations _auth_object = nil
    %w(user)
  end

  def all_requests_checked_out?
    requests.all? {|req| req.status == Request::CHECKED_OUT_STATUS}
  end

  def send_confirmation_email
    BookingMailer.booking_confirmation(self).deliver_later
  end

  def send_decline_email
    BookingMailer.booking_decline(self).deliver_later
  end

  private

  def cascade_requests_on_confirm
    requests.where(status: :pending).find_each do |req|
      req.update(status: :confirmed)
    end
  end

  def cascade_requests_on_decline
    requests.where(status: :pending).find_each do |req|
      req.update(status: :declined)
    end
  end
end
