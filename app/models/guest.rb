class Guest < ApplicationRecord
  belongs_to :request

  enum identity_type: {
    national_id: 0,
    passport: 1,
    identity_number: 2
  }, _prefix: true
end
