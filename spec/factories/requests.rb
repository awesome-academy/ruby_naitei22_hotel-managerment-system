FactoryBot.define do
  factory :request do
    association :booking
    association :room
    check_in { DateTime.current + 1.day }
    check_out { DateTime.current + 3.days }
    number_of_guests { 2 }
    note { "Sample note" }
    status { :pending }

    trait :checked_out do
      status { :checked_out }
    end
  end
end
