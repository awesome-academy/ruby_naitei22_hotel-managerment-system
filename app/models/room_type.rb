class RoomType < ApplicationRecord
  ROOM_TYPE_PARAMS = %i(name description).freeze

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  before_destroy :check_for_rooms

  # Associations
  has_many :rooms, dependent: :destroy

  def self.ransackable_attributes _ = nil
    %w(name description)
  end

  def number_of_rooms
    rooms.count
  end

  private

  def check_for_rooms
    return unless rooms.exists?

    errors.add(:base, :cannot_delete_with_rooms)
    throw(:abort)
  end
end
