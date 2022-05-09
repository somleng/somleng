class User < ApplicationRecord
  extend Enumerize
  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\z/

  enumerize :carrier_role, in: %i[owner admin member], predicates: true

  belongs_to :carrier
  belongs_to :current_account_membership, optional: true, class_name: "AccountMembership"
  has_many :exports
  has_many :imports
  has_many :account_memberships
  has_many :accounts, through: :account_memberships

  devise :invitable, :registerable, :confirmable,
         :recoverable, :validatable, :trackable, :rememberable,
         :two_factor_authenticatable,
         reconfirmable: true

  before_create :generate_otp_secret

  def self.policy_class
    CarrierUserPolicy
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  def generate_otp_secret
    self.otp_secret ||= User.generate_otp_secret
  end
end
