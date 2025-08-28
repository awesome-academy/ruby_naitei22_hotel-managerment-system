FactoryBot.define do
  factory :room_availability do
    association :room
    sequence(:available_date) { |n| Date.today + 61.days + n }
    price { 100 }
    is_available { true }
  end
end
