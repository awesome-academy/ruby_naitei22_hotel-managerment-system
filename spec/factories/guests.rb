FactoryBot.define do
  factory :guest do
    association :request
    full_name { "Guest #{Faker::Name.name}" }
    identity_type { :national_id }
    sequence(:identity_number) { |n| ("%012d" % n) }
    identity_issued_date { Date.today - 1.day }
    identity_issued_place { "HN" }
  end
end
