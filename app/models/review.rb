class Review < ApplicationRecord
  belongs_to :user
  belongs_to :request
  belongs_to :approved_by, class_name: User.name, optional: true

  delegate :booking, to: :request
  delegate :room, to: :request

  enum review_status: {
    pending: 0,
    approved: 1,
    rejected: 2
  }, _prefix: true

  ASSOCIATIONS_PRELOAD = [:user, :approved_by,
                         {request: [:booking, :room]}].freeze
  RATINGS = (1..5).to_a.freeze
  NA = "N/A".freeze

  scope :by_review_id, -> {order(id: :desc)}

  def self.ransackable_attributes _auth_object = nil
    %w(review_status rating)
  end

  def self.ransackable_associations _auth_object = nil
    %w(user request booking room)
  end
end
