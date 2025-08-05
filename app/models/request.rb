class Request < ApplicationRecord
  has_many :room_availability_requests, dependent: :destroy
  has_many :room_availabilities, through: :room_availability_requests
  belongs_to :booking
  belongs_to :review

  enum status: {
    draft: 0,
    pending: 1,
    confirmed: 2,
    declined: 3,
    cancelled: 4,
    checked_in: 5,
    checked_out: 6
  }, _prefix: true
end
