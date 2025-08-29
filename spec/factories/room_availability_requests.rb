FactoryBot.define do
  factory :room_availability_request do
    association :room_availability
    association :request
  end
end
