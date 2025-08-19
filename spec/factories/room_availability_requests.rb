FactoryBot.define do
  factory :room_availability_request do
    association :request
    association :room_availability
  end
end
