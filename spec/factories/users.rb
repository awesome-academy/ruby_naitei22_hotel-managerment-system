FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User#{n}" }
    password { "password" }
    confirmed_at { Time.current }
    role { "user" }
  end
end
