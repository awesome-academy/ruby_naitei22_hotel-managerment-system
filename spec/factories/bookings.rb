FactoryBot.define do
  factory :booking do
    sequence(:booking_code) { |n| "B#{n.to_s.rjust(5, "0")}" }
    booking_date { Date.today }
    status { "draft" }
    association :user   # nếu có quan hệ belongs_to :user
  end
end
