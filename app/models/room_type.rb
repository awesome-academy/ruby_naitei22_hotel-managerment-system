class RoomType < ApplicationRecord
  ROOM_TYPE_PARAMS = %i(name description).freeze

  validates :name, presence: true
  validates :description, presence: true

  # Associations
  has_many :rooms, dependent: :destroy

  def self.ransackable_attributes _ = nil
    %w(name)
  end

  def number_of_rooms
    rooms.count
  end
end
