class Carrier < ApplicationRecord
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
  has_many :custom_domains

  has_one_attached :logo

  def self.from_domain(host:, type:)
    joins(:custom_domains)
      .where(custom_domains: { host:, type: })
      .merge(CustomDomain.verified).first
  end

  def country
    ISO3166::Country.new(country_code)
  end

  def api_key
    oauth_application.access_tokens.last.token
  end

  def webhooks_enabled?
    webhook_endpoint&.enabled?
  end

  def custom_domain(type)
    custom_domains.find_by(type:)
  end
end
