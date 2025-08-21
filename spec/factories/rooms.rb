FactoryBot.define do
  factory :room do
    room_number { Faker::Number.unique.number(digits: 3) }
    capacity { Faker::Number.between(from: 1, to: 5) }
    description { Faker::Lorem.sentence }
    price { Faker::Number.between(from: 50, to: 500) }
    price_from_date { Date.today }
    price_to_date { Date.today + 60.days }
    association :room_type
  end
end
