class Review < ApplicationRecord
  belongs_to :user
  belongs_to :request
  belongs_to :approved_by, class_name: User.name, optional: true

  enum review_status: {
    pending: 0,
    approved: 1,
    rejected: 2
  }, _prefix: true
end
