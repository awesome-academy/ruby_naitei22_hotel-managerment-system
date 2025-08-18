class Amenity < ApplicationRecord
  AMENITY_PARAMS = %i(name description).freeze

  has_many :room_amenities, dependent: :destroy
  has_many :rooms, through: :room_amenities

  validates :name, presence: true
  validates :description, length: {maximum: 255}, allow_blank: true

  class << self
    def ransackable_attributes _auth_object = nil
      %w(name description)
    end
  end
end
