class Amenity < ApplicationRecord
  AMENITY_PARAMS = %i(name description).freeze

  has_many :room_amenities, dependent: :destroy
  has_many :rooms, through: :room_amenities

  validates :name, presence: true
  validates :description, length: {maximum: 255}, allow_blank: true

  before_destroy :check_for_rooms

  class << self
    def ransackable_attributes _auth_object = nil
      %w(name description)
    end
  end

  private

  def check_for_rooms
    return unless rooms.exists?

    errors.add(:base, :cannot_delete_with_rooms)
    throw(:abort)
  end
end
