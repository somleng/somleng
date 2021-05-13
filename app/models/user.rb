class User < ApplicationRecord
  extend Enumerize

  enumerize :role, in: %i[admin member], predicates: true, default: :admin

  belongs_to :carrier, optional: true
  belongs_to :account, optional: true

  devise :invitable, :registerable,
         :recoverable, :validatable, :trackable, :rememberable,
         :two_factor_authenticatable,
         otp_secret_encryption_key: Rails.configuration.app_settings.fetch(:otp_secret_encryption_key)

  before_create :generate_otp_secret

  private

  def generate_otp_secret
    self.otp_secret ||= User.generate_otp_secret
  end
end
