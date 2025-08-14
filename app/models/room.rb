class Room < ApplicationRecord
  belongs_to :room_type

  has_many :room_amenities, dependent: :destroy
  has_many :amenities, through: :room_amenities

  has_many :room_availabilities, dependent: :destroy
  has_many :room_availability_requests, through: :room_availabilities
  has_many :requests, through: :room_availability_requests
  has_many :reviews, through: :requests

  has_many_attached :images

  enum status: {
    available: 0,
    occupied: 1,
    maintenance: 2
  }, _prefix: true

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
    reviews.average(:rating)&.round(1) || 0
  end

  def number_of_rating
    reviews.count(:id)
  end
end
