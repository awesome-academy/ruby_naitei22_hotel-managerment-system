FactoryBot.define do
  factory :room_availability do
    association :room
    is_available { true }
    price { 100 }

    trait :unavailable do
      is_available { false }
    end
  end
end
