FactoryBot.define do
  factory :review do
    association :user
    association :request, factory: [:request, :checked_out]
    association :approved_by, factory: [:user, :admin]
    rating {rand(1..5)}
    comment {"This is a sample review comment"}
  end
end
