class User < ApplicationRecord
  has_secure_password
  # cung cap xac thuc mat khau cho model user
  # tu them cac truong:
  # password: khong luu vao csdl
  # password_confirmation
  # password_digest: luu password vao csdl duoi dang hash
  # xac thuc mat khau bang authenticate(password)

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  NAME_MAX_LENGTH = 50
  EMAIL_MAX_LENGTH = 255

  USER_PERMIT = %i(
    name
    email
    date_of_birth
    gender
    password
    password_confirmation
  ).freeze

  GENDERS = {
    male: "male",
    female: "female",
    other: "other"
  }.freeze

  attr_accessor :remember_token

  before_save :downcase_email

  scope :recent, ->{order(created_at: :desc)} # thu tu giam dan

  validates :name, presence: true, length: {maximum: NAME_MAX_LENGTH}
  validates :email, presence: true, length: {maximum: EMAIL_MAX_LENGTH},
format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  # validation cua email se khong phan biet CHU HOA va chu thuong
  validate :date_of_birth_must_be_within_last_100_years

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

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  private

  def downcase_email
    email.downcase!
  end
  # downcase_email se chay truoc khi luu user vao csdl
  # lam cho tat ca ky tu cua email thanh chu thuong

  def date_of_birth_must_be_within_last_100_years
    return if date_of_birth.blank?

    if date_of_birth < 100.years.ago.to_date || date_of_birth > Time.zone.today
      errors.add(:date_of_birth, :invalid_range)
    end
  end
end
