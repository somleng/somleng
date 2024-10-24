class User < ApplicationRecord
  extend Enumerize
  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\z/

  enumerize :carrier_role, in: %i[owner admin member], predicates: true
  enumerize :subscribed_notification_topics,
            in: [
              "error_logs.inbound_message",
              "error_logs.inbound_call",
              "error_logs.sms_gateway_disconnect"
            ],
            multiple: true

  belongs_to :carrier
  belongs_to :current_account_membership,
             optional: true,
             class_name: "AccountMembership"

  has_many :exports, dependent: :destroy
  has_many :imports
  has_many :account_memberships
  has_many :accounts, through: :account_memberships
  has_many :error_log_notifications

  devise :invitable, :registerable, :confirmable,
         :recoverable, :trackable, :rememberable,
         :two_factor_authenticatable, :lockable,
         reconfirmable: true

  validates :email,
            presence: true,
            format: { with: Devise.email_regexp, allow_blank: true, if: :email_changed? }

  validates :email,
            uniqueness: {
              scope: :carrier_id,
              allow_blank: true,
              if: :email_changed?
            }

  validates :password,
            presence: { if: :password_required? },
            confirmation: { if: :password_required? },
            length: { within: Devise.password_length, allow_blank: true }

  before_create :set_defaults

  def self.policy_class
    CarrierUserPolicy
  end

  def self.find_for_authentication(warden_conditions)
    app_request = AppRequest.new(warden_conditions.fetch(:itself))
    joins(:carrier).where(
      email: warden_conditions[:email],
      carriers: { subdomain: app_request.carrier_subdomain }
    ).first
  end

  def self.carrier
    where.not(carrier_role: nil)
  end

  def self.subscribed_to_notifications_for(topic)
    where(":topic = ANY (\"#{table_name}\".\"subscribed_notification_topics\")", topic:)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def carrier_user?
    carrier_role.present?
  end

  private

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  def set_defaults
    self.otp_secret ||= User.generate_otp_secret
  end
end
