class User < ApplicationRecord
  extend Enumerize

  enumerize :carrier_role, in: %i[owner admin member], predicates: true

  belongs_to :carrier, optional: true
  belongs_to :account, optional: true
  has_many :exports

  devise :invitable, :registerable,
         :recoverable, :validatable, :trackable, :rememberable,
         :two_factor_authenticatable,
         otp_secret_encryption_key: Rails.configuration.app_settings.fetch(:otp_secret_encryption_key)

  before_create :generate_otp_secret

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  def generate_otp_secret
    self.otp_secret ||= User.generate_otp_secret
  end
end
