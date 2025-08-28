FactoryBot.define do
  factory :room_amenity do
    association :room
    association :amenity
  end
end
