class Amenity < ApplicationRecord
  has_many :room_amenities, dependent: :destroy
  has_many :rooms, through: :room_amenities
end
