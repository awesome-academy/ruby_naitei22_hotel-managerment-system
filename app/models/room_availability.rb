class RoomAvailability < ApplicationRecord
  belongs_to :room
  has_one :room_type, through: :room

  has_many :room_availability_requests, dependent: :destroy
  has_many :requests, through: :room_availability_requests

  delegate :room_number, :capacity, :room_type, to: :room
  delegate :name, to: :room_type, prefix: true

  scope :for_date, ->(date) {where(available_date: date)}
  scope :available, -> {where(is_available: true)}
  scope :unavailable, -> {where(is_available: false)}

  # Order by available_date then rooms.room_number
  scope :ordered, (lambda do
    joins(:room).order(
      available_date: :asc,
      "rooms.room_number": :asc
    )
  end)

  # Preload associations to avoid N+1 queries
  ASSOCIATIONS_PRELOAD = [
    {room: :room_type}
  ].freeze

  def status
    is_available ? :available : :unavailable
  end

  def self.ransackable_attributes _auth_object = nil
    %w(available_date is_available)
  end

  def self.ransackable_associations _auth_object = nil
    %w(room room_type)
  end
end
