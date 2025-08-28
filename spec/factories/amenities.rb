FactoryBot.define do
  factory :amenity do
    sequence(:name) { |n| "Amenity #{n}" }
    description { Faker::Lorem.sentence }
  end
end
