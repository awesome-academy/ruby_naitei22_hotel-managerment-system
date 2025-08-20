FactoryBot.define do
  factory :room_type do
    sequence(:name) { |n| "Type #{n}" }
    description { "Single bed." }
    price { 100 }
  end
end
