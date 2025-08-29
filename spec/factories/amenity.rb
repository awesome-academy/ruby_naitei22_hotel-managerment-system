FactoryBot.define do
  factory :amenity do
    sequence(:name) { |n| "Amenity #{n}" }
    sequence(:description) { |n| "Mô tả phòng ##{n}: tiện nghi cơ bản, phù hợp 2 khách." }
  end
end
