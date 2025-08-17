class User < ApplicationRecord
  has_secure_password
  # cung cap xac thuc mat khau cho model user
  # tu them cac truong:
  # password: khong luu vao csdl
  # password_confirmation
  # password_digest: luu password vao csdl duoi dang hash
  # xac thuc mat khau bang authenticate(password)
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :approved_reviews,
           class_name: Review.name,
           foreign_key: "approved_by_id",
           dependent: :nullify
  has_many :status_changed_bookings,
           class_name: Booking.name,
           foreign_key: "status_changed_by_id",
           dependent: :nullify

  enum role: {
    user: 0,
    admin: 1
  }, _prefix: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  NAME_MAX_LENGTH = 50
  EMAIL_MAX_LENGTH = 255

  USER_PERMIT = %i(
    name
    email
    phone
    password
    password_confirmation
  ).freeze

  attr_accessor :remember_token, :activation_token

  before_save :downcase_email
  before_create :create_activation_digest

  scope :recent, -> {order(created_at: :desc)}

  scope :with_total_created_bookings, (lambda do
    select(
      "users.*, " \
      "COUNT(CASE WHEN bookings.status != #{Booking.statuses[:draft]} " \
      "THEN 1 END) AS total_created_bookings"
    )
      .left_joins(:bookings)
      .group("users.id")
  end)

  validates :name, presence: true, length: {maximum: NAME_MAX_LENGTH}
  validates :email, presence: true, length: {maximum: EMAIL_MAX_LENGTH},
format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  # Forgets a user.
  def forget
    update_column :remember_digest, nil
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  # Activates an account
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def status
    activated ? :active : :unactive
  end

  def total_bookings
    bookings.count
  end

  # Index: use scope with_total_created_bookings
  #   => ActiveRecord adds a virtual attribute total_created_bookings,
  #      avoid N+1 queries
  # Show: calculate directly with association (bookings.where...)
  #   => For a single record, this query is simple and
  #      more efficient than joining tables
  def total_created_bookings
    if has_attribute?(:total_created_bookings)
      self[:total_created_bookings].to_i
    else
      bookings.where.not(status: :draft).count
    end
  end

  def total_successful_bookings
    bookings.where(status: [:confirmed, :completed]).count
  end

  def total_cancelled_bookings
    bookings.where(status: :cancelled).count
  end

  def total_pending_bookings
    bookings.where(status: :pending).count
  end

  def total_spending
    bookings
      .joins(requests: :room_availabilities)
      .where(status: [:confirmed, :completed])
      .sum("room_availabilities.price")
  end

  def self.ransackable_attributes _auth_object = nil
    %w(name email phone activated)
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
