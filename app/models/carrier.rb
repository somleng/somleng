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
  has_one :custom_dashboard_domain, -> { where(type: :dashboard) }, class_name: "CustomDomain"
  has_one :custom_api_domain, -> { where(type: :api) }, class_name: "CustomDomain"

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
end
