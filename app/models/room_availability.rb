class RoomAvailability < ApplicationRecord
  belongs_to :room
  has_many :room_availability_requests, dependent: :destroy
  has_many :requests, through: :room_availability_requests
end
