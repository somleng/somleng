class Carrier < ApplicationRecord
  extend Enumerize

  MAX_RESTRICTED_INTERACTIONS_PER_MONTH = 100

  enumerize :status, in: %i[disabled restricted enabled], predicates: true

  has_many :accounts
  has_many :account_memberships, through: :accounts
  has_many :account_users, through: :accounts, source: :users, class_name: "User"
  has_many :users
  has_many :inbound_sip_trunks
  has_many :outbound_sip_trunks
  has_many :phone_numbers
  has_many :phone_calls
  has_many :events
  has_many :interactions
  has_one :oauth_application, as: :owner
  has_one :webhook_endpoint, through: :oauth_application

  has_one_attached :logo

  def country
    ISO3166::Country.new(country_code)
  end

  def api_key
    oauth_application.access_tokens.last.token
  end

  def webhooks_enabled?
    webhook_endpoint&.enabled?
  end

  def good_standing?
    return false unless enabled? || restricted?

    !restricted? || remaining_interactions.positive?
  end

  def remaining_interactions
    [(MAX_RESTRICTED_INTERACTIONS_PER_MONTH - interactions.this_month.count), 0].max
  end
end
