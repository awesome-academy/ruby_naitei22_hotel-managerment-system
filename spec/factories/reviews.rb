FactoryBot.define do
  factory :review do
    rating { 5 }
    comment { "Good" }
    review_status { "pending" }
    association :user
    association :request
  end
end
