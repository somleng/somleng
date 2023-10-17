class Account < ApplicationRecord
  extend Enumerize
  TYPES = %w[customer_managed carrier_managed].freeze

  enumerize :status, in: %i[enabled disabled], predicates: true, default: :enabled

  belongs_to :carrier
  belongs_to :sip_trunk, optional: true

  has_one :access_token,
          class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id,
          dependent: :destroy

  has_many :phone_calls, dependent: :restrict_with_error
  has_many :messages, dependent: :restrict_with_error
  has_many :messaging_services
  has_many :phone_numbers, dependent: :restrict_with_error
  has_many :account_memberships, dependent: :restrict_with_error
  has_many :users, through: :account_memberships
  has_many :recordings
  has_many :error_logs
  has_many :interactions
  has_many :tts_events

  def self.customer_managed
    where(arel_table[:account_memberships_count].gt(0))
  end

  def self.carrier_managed
    where(account_memberships_count: 0)
  end

  def auth_token
    access_token.token
  end

  def type
    account_memberships_count.positive? ? "customer_managed" : "carrier_managed"
  end

  def carrier_managed?
    type == "carrier_managed"
  end

  def customer_managed?
    type == "customer_managed"
  end

  def owner
    account_memberships.owner.first&.user
  end
end
