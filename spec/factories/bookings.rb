FactoryBot.define do
  factory :booking do
    sequence(:booking_code) { |n| "BKA#{n}" }
    booking_date { Date.today }
    status { "draft" }
    association :user   # nếu có quan hệ belongs_to :user
  end
end
