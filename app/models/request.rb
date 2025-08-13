class Request < ApplicationRecord
  UNAVAILABLE_STATUSES = %w(pending confirmed checked_in checked_out).freeze

  has_many :review, dependent: :destroy
  has_many :room_availability_requests, dependent: :destroy
  has_many :room_availabilities, through: :room_availability_requests
  belongs_to :booking

  after_update :update_room_availability_status

  enum status: {
    draft: 0,
    pending: 1,
    confirmed: 2,
    declined: 3,
    cancelled: 4,
    checked_in: 5,
    checked_out: 6
  }, _prefix: true

  private

  def update_room_availability_status
    if UNAVAILABLE_STATUSES.include?(status)
      room_availabilities.update_all(is_available: false)
    else
      room_availabilities.update_all(is_available: true)
    end
  end
end
