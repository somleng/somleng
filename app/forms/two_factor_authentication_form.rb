class TwoFactorAuthenticationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user
  attribute :otp_attempt

  validates :otp_attempt, presence: true
  validate :validate_otp_attempt

  def self.model_name
    ActiveModel::Name.new(self, nil, "TwoFactorAuthentication")
  end

  def persisted?
    false
  end

  def save
    return false unless valid?

    user.update!(otp_required_for_login: true)
  end

  private

  def validate_otp_attempt
    return if otp_attempt.blank?

    errors.add(:otp_attempt, :invalid) unless user.validate_and_consume_otp!(otp_attempt)
  end
end
