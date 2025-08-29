FactoryBot.define do
  factory :guest do
    association :request

    sequence(:full_name) {|n| "Nguyen Van #{n}"}
    identity_type {:national_id}
    sequence(:identity_number) {|n| "12345678901#{n % 10}"}
    identity_issued_date {2.years.ago.to_date}
    identity_issued_place {"Ha Noi"}

    trait :with_passport do
      identity_type {:passport}
      sequence(:identity_number) {|n| "a123456#{n % 10}"}
    end

    trait :with_identity_card do
      identity_type {:identity_number}
      sequence(:identity_number) {|n| "98765432101#{n % 10}"}
    end
  end
end
