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

  scope :by_room_type, lambda {|room_type|
    return all if room_type.blank?

    joins(:room_type).where(room_types: {name: room_type})
  }

  scope :by_price_range, lambda {|price_range|
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
  }

  scope :sorted, lambda {|sort_by|
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
  }

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
