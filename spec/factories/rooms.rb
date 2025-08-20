FactoryBot.define do
  factory :room do
    sequence(:room_number) { |n| "Room#{n}-#{SecureRandom.hex(2)}" }
    capacity { 1 }
    description { "Hotel's room." }
    price_from_date {Date.today + 365.days}
    price_to_date {Date.tomorrow + 365.days}
    price {100}
    association :room_type
  end
end
