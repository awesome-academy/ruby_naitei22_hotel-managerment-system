FactoryBot.define do
  factory :request do
    association :booking
    association :room
    check_in { Date.today }
    check_out { Date.tomorrow }
    status { :draft }
  end
end
