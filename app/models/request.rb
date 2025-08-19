class Request < ApplicationRecord
  UNAVAILABLE_STATUSES = %w(pending confirmed checked_in checked_out).freeze

  REQUEST_PERMIT = %i(
    room_id
    check_in
    check_out
    number_of_guests
    note
  ).freeze

  after_initialize :set_default_status, if: :new_record?
  after_update :update_room_availability_status

  ASSOCIATIONS_REQUEST_PRELOAD = [:booking, :guests,
  {room_availabilities: {room: :room_type}}].freeze

  CHECKED_OUT_STATUS = "checked_out".freeze

  enum status: {
    draft: 0,
    pending: 1,
    confirmed: 2,
    declined: 3,
    cancelled: 4,
    checked_in: 5,
    checked_out: 6
  }, _prefix: true

  has_many :reviews, dependent: :destroy
  has_many :room_availability_requests, dependent: :destroy
  has_many :room_availabilities, through: :room_availability_requests
  has_many :guests, dependent: :destroy
  belongs_to :booking
  belongs_to :room

  validates :check_in, :check_out, presence: true
  validate  :check_in_before_check_out, if: :check_times_changed?
  validate  :validate_check_in, if: :check_times_changed?

  def calculate_price
    return nil unless check_in && check_out && room.present?

    if check_in == check_out
      availabilities = room.room_availabilities
                           .where(available_date: check_in)
    else
      availabilities = room.room_availabilities
                           .where(available_date: check_in..check_out)
    end

    return nil if availabilities.empty?

    availabilities.sum(:price)
  end

  def self.ransackable_attributes _auth_object = nil
    %w()
  end

  def self.ransackable_associations _auth_object = nil
    %w(booking room)
  end

  private

  def check_in_before_check_out
    return if check_in.blank? || check_out.blank?

    errors.add(:check_out, :check_in_before_check_out) if check_out < check_in
  end

  def check_times_changed?
    will_save_change_to_check_in? || will_save_change_to_check_out?
  end

  def validate_check_in
    return if check_in.blank?
    return if check_in >= Time.zone.today

    errors.add(:check_in, :future)
  end

  def set_default_status
    self.status ||= :draft
  end

  def update_room_availability_status
    if UNAVAILABLE_STATUSES.include?(status)
      room_availabilities.update_all(is_available: false)
    else
      room_availabilities.update_all(is_available: true)
    end
  end
end
