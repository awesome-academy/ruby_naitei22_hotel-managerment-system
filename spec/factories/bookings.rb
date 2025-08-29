FactoryBot.define do
  factory :booking do
    association :user
    status {:pending}
    sequence(:booking_code) {|n| "B%05d" % n}

    trait :confirmed do
      status {:confirmed}
    end

    trait :completed do
      status {:completed}
    end
  end
end
