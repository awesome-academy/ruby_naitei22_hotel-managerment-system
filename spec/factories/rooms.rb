FactoryBot.define do
  factory :room do
    association :room_type
    sequence(:room_number) { |n| "Room #{n}" }
    capacity { 2 }
    description { "A comfortable room" }
    price_from_date { Date.current }
    price_to_date { Date.current + 1.year }
    price { 100.00 }
  end
end
