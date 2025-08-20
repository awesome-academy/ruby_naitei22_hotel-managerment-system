FactoryBot.define do
  factory :room_availability do
    association :room
    sequence(:available_date) { Date.today }
    price { 100 }
    is_available { true }
  end
end
