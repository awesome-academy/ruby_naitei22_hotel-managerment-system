class Room < ApplicationRecord
  belongs_to :roomtype
  has_many :room_amenities, dependent: :destroy
  has_many :amenities, through: :room_amenities

  has_many :room_availabilities, dependent: :destroy
  has_many :room_availability_requests, dependent: :destroy
  has_many :requests, through: :room_availability_requests

  has_many_attached :images

  enum status: {
    available: 0,
    occupied: 1,
    maintenance: 2
  }, _prefix: true
end
