FactoryBot.define do
  factory :room_type do
    sequence(:name) { |n| "Room Type #{n}" }
    description { Faker::Lorem.paragraph }
  end
end
