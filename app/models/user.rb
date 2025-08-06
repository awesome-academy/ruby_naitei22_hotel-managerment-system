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

  GENDERS = {
    male: "male",
    female: "female",
    other: "other"
  }.freeze

  attr_accessor :remember_token, :activation_token

  before_save :downcase_email
  before_create :create_activation_digest

  scope :recent, ->{order(created_at: :desc)} # thu tu giam dan

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

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
