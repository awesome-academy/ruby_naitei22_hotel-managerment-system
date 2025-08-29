FactoryBot.define do
  factory :room_type do
    sequence(:name) {|n| "Room Type #{n}"}
    sequence(:description) {|n| "Description for Room Type #{n}"}
  end
end
