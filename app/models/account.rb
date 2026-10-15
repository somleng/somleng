class Account < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  enumerize :type, in: [ :carrier_managed, :customer_managed ], predicates: true, scope: :shallow
  enumerize :status, in: %i[enabled disabled], predicates: true, default: :enabled
  enumerize :billing_mode, in: [ :prepaid ], predicates: true, default: :prepaid

  attribute :default_tts_voice, TTSVoiceType.new
  attribute :billing_currency, CurrencyType.new

  belongs_to :carrier
  belongs_to :sip_trunk, optional: true
  belongs_to :primary_auth_token, class_name: "AuthToken"

  has_many :auth_tokens,
           class_name: "AuthToken",
           foreign_key: :resource_owner_id

  has_many :phone_calls, dependent: :restrict_with_error
  has_many :messages, dependent: :restrict_with_error
  has_many :messaging_services
  has_many :verification_services
  has_many :verifications
  has_many :phone_number_plans
  has_many :incoming_phone_numbers
  has_many :available_phone_numbers, ->(account) { public.where(currency: account.billing_currency)  }, through: :carrier
  has_many :account_memberships, dependent: :restrict_with_error
  has_many :users, through: :account_memberships
  has_many :recordings
  has_many :error_logs
  has_many :interactions
  has_many :tts_events
  has_many :tariff_plan_subscriptions, inverse_of: :account
  has_many :tariff_plans, through: :tariff_plan_subscriptions, source: :plan
  has_many :balance_transactions

  before_create :set_defaults
  before_validation :set_primary_auth_token, on: :create

  def self.billing_enabled
    where(billing_enabled: true)
  end

  def owner
    account_memberships.owner.first&.user
  end

  def auth_token
    primary_auth_token.token
  end

  private

  def set_defaults
    return if carrier.blank?

    self.billing_currency ||= carrier.billing_currency
  end

  def set_primary_auth_token
    return if primary_auth_token.present?

    self.primary_auth_token = auth_tokens.new
  end
end
