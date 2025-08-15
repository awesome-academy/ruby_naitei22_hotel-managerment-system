class Guest < ApplicationRecord
  belongs_to :request

  GUEST_PARAMS = %i(full_name identity_type identity_number
  identity_issued_date identity_issued_place).freeze
  VALID_NATIONAL_ID_REGEX = /\A\d{12}\z/
  VALID_PASSPORT_REGEX = /\A[a-z]\d{7}\z/

  enum identity_type: {
    national_id: 0,
    passport: 1,
    identity_number: 2
  }, _prefix: true

  validates :full_name, presence: true
  validates :identity_type, presence: true
  validates :identity_number, presence: true
  validates :identity_issued_date, presence: true
  validates :identity_issued_place, presence: true
  validate :validate_identity_date
  validate :validate_national_id_identity_number
  validate :validate_passport

  private

  def validate_identity_date
    return if identity_issued_date.blank?
    return if identity_issued_date <= Time.zone.today

    errors.add(:identity_issued_date, :future)
  end

  def validate_national_id_identity_number
    return if identity_number.blank? || identity_type.blank?
    return unless identity_type_national_id? || identity_type_identity_number?

    return if identity_number.match?(VALID_NATIONAL_ID_REGEX)

    errors.add(:identity_number, :invalid_national_id)
  end

  def validate_passport
    return if identity_number.blank? || identity_type.blank?

    return unless identity_type_passport?

    return if identity_number.match?(VALID_PASSPORT_REGEX)

    errors.add(:identity_number, :invalid_passport)
  end
end
