FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    password { "password" }
    password_confirmation { "password" }

    trait :admin do
      role { :admin }
    end
  end
end
