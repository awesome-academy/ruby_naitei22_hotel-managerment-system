FactoryBot.define do
  factory :guest do
    full_name { "Nguyen Van A" }
    identity_type { 0 }
    identity_number { "00000000#{rand(1000..9999)}" }
    identity_issued_date { Date.today - 365.days }
    identity_issued_place { "Hanoi" }
    association :request
  end
end
