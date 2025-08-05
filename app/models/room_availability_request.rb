class RoomAvailabilityRequest < ApplicationRecord
  belongs_to :room_availability
  belongs_to :request
end
