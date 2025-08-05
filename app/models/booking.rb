class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :status_changed_by, class_name: User.name, optional: true
  has_many :requests, dependent: :destroy

  enum status: {
    draft: 0,
    pending: 1,
    confirmed: 2,
    declined: 3,
    cancelled: 4,
    completed: 5
  }, _prefix: true
end
