FactoryBot.define do
  factory :room do
    sequence(:room_number) { |n| "Room#{n}-#{SecureRandom.hex(2)}" }
    capacity { Faker::Number.between(from: 1, to: 5) }
    description { Faker::Lorem.sentence }
    price { Faker::Number.between(from: 50, to: 500) }
    price_from_date { Date.today }
    price_to_date { Date.today + 60.days }
    association :room_type
  end
end
