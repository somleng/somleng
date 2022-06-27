class Carrier < ApplicationRecord
  has_many :accounts
  has_many :account_memberships, through: :accounts
  has_many :account_users, through: :accounts, source: :users, class_name: "User"
  has_many :carrier_users, -> { where.not(carrier_role: nil) }, class_name: "User"
  has_many :inbound_sip_trunks
  has_many :outbound_sip_trunks
  has_many :phone_numbers
  has_many :phone_calls
  has_many :events
  has_many :error_logs
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

  def subdomain_host
    uri = Addressable::URI.parse(url_helpers.root_url(subdomain: "#{subdomain}.app"))
    uri.port.present? ? "#{uri.host}:#{uri.port}" : uri.host
  end

  def account_host
    custom_app_host.present? ? custom_app_host : subdomain_host
  end

  private

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end
end
