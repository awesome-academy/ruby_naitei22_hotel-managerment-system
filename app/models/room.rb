class Room < ApplicationRecord
  RESIZE_LIMIT_SMALL = [300, 300].freeze
  RESIZE_LIMIT_LARGE = [600, 300].freeze
  DIGIT_5 = 5
  DIGIT_140 = 140
  ROOM_PARAMS = [
    :room_number,
    :room_type_id,
    :capacity,
    :description,
    :price_from_date,
    :price_to_date,
    :price,
    {images: [],
     amenity_ids: []}
  ].freeze

  # Fields to create a range of room_availabilities
  attribute :price_from_date, :date
  attribute :price_to_date, :date
  attribute :price, :decimal, precision: 10, scale: 2

  validates :room_number, presence: true, uniqueness: true
  validates :room_type_id, presence: true
  validates :capacity, presence: true,
              numericality: {only_integer: true, greater_than: 0}
  validates :description, presence: true, length: {maximum: DIGIT_140}

  # Create: Admin is required to enter all 3 fields
  validates :price_from_date, :price_to_date, :price,
            presence: true,
            on: :create

  # UPDATE: If admin enter 1 field then all fields are required
  validates :price_from_date, :price_to_date, :price,
            presence: true,
            if: :price_fields_partially_filled?

  validates :price, numericality: {greater_than: 0}, if: -> {price.present?}

  # If price fields are filled, validate their dates
  validate :validate_price_dates

  after_save :upsert_range_prices
  before_destroy :check_for_requests

  # Associations
  belongs_to :room_type

  has_many :room_amenities, dependent: :destroy
  has_many :amenities, through: :room_amenities

  has_many :room_availabilities, dependent: :destroy
  has_many :room_availability_requests, through: :room_availabilities
  has_many :requests, through: :room_availability_requests
  has_many :requests, dependent: :destroy
  has_many :reviews, through: :requests

  has_many_attached :images do |attachable|
    attachable.variant :small, resize_to_limit: RESIZE_LIMIT_SMALL
    attachable.variant :large, resize_to_limit: RESIZE_LIMIT_LARGE
  end

  def self.ransackable_attributes _auth_object = nil
    %w(room_number)
  end

  def self.ransackable_associations _auth_object = nil
    %w(room_type)
  end

  scope :available_on, (lambda do |check_in = nil, check_out = nil|
    start_date = check_in.present? ? check_in.to_date : Time.zone.today
    end_date   = check_out.present? ? check_out.to_date : start_date

    return none if start_date > end_date

    where.not(
      id: Room.joins(:room_availabilities)
              .joins(room_availabilities: :room_availability_requests)
              .joins(room_availability_requests: :request)
              .where(requests: {
                       check_in: ..end_date + 1,
                       check_out: start_date..,
                       status: Request::UNAVAILABLE_STATUSES
                     })
              .select(:id)
              .distinct
    )
  end)

  scope :by_room_type, (lambda do |room_type|
    return all if room_type.blank?

    joins(:room_type).where(room_types: {name: room_type})
  end)

  scope :by_price_range, (lambda do |price_range|
    conditions = {
      "below_50" => ["room_types.price < ?", 50],
      "50_99" => ["room_types.price BETWEEN ? AND ?",
50, 99],
      "100_200" => ["room_types.price BETWEEN ? AND ?",
100, 200],
      "above_200" => ["room_types.price > ?", 200]
    }

    if conditions.key?(price_range)
      joins(:room_type).where(conditions[price_range])
    else
      all
    end
  end)

  scope :sorted, (lambda do |sort_by|
    case sort_by
    when "price_asc"
      sort_by_price_asc
    when "price_desc"
      sort_by_price_desc
    when "rating_desc"
      sort_by_rating_desc
    else
      all
    end
  end)

  scope :sort_by_price_asc, (lambda do
    joins(:room_type).order("room_types.price ASC")
  end)

  scope :sort_by_price_desc, (lambda do
    joins(:room_type).order("room_types.price DESC")
  end)

  scope :sort_by_rating_desc, (lambda do
    left_joins(requests: :review)
      .group("rooms.id")
      .order(Arel.sql("AVG(reviews.rating) IS NULL, AVG(reviews.rating) DESC"))
  end)

  def average_rating
    reviews.where(review_status: :approved).average(:rating)&.round(1) || 0
  end

  def number_of_rating
    reviews.where(review_status: :approved).distinct.count(:id)
  end

  def available_dates
    room_availabilities
      .where(is_available: true)
      .pluck(:available_date)
  end

  def total_price_for_dates check_in, check_out
    return 0 if check_in.blank? || check_out.blank? || check_in >= check_out

    room_availabilities
      .where(available_date: check_in...check_out)
      .sum(:price)
  end

  private

  def price_fields_partially_filled?
    price_from_date.present? || price_to_date.present? || price.present?
  end

  def validate_price_dates
    return if price_from_date.blank? || price_to_date.blank?

    current_date = Time.zone.today

    errors.add(:price_from_date, :in_past) if price_from_date < current_date

    errors.add(:price_to_date, :in_past) if price_to_date < current_date

    return unless price_from_date > price_to_date

    errors.add(:price_to_date, :before_start_date)
  end

  def check_for_requests
    return unless requests.where(status: Request::UNAVAILABLE_STATUSES).exists?

    errors.add(:base, :cannot_delete_with_requests)
    throw(:abort)
  end

  def upsert_range_prices
    return if price.blank? || price_from_date.blank? || price_to_date.blank?

    RoomAvailabilities::UpsertRange.new(
      self,
      from: price_from_date,
      to: price_to_date,
      price:
    ).call
  rescue ActiveRecord::ActiveRecordError
    errors.add(:base, :failed_to_upsert_prices)
    raise ActiveRecord::Rollback
  end
end
