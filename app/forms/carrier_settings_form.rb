class CarrierSettingsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  COUNTRIES = ISO3166::Country.all.map(&:alpha2).freeze

  class HostnameValidator < ActiveModel::EachValidator
    RESTRICTED_DOMAINS = [
      AppSettings.app_uri.domain
    ].freeze

    def validate_each(record, attribute, value)
      return if value.blank?

      if Addressable::URI.parse("//#{value}").domain.in?(RESTRICTED_DOMAINS)
        return record.errors.add(attribute, :exclusion)
      end

      scope = options.fetch(:scope) { ->(_) { Carrier } }
      return record.errors.add(attribute, :taken) if scope.call(record).exists?(attribute => value)
    rescue Addressable::URI::InvalidURIError
      record.errors.add(attribute, :invalid)
    end
  end

  attribute :carrier
  attribute :name
  attribute :country
  attribute :website
  attribute :subdomain, SubdomainType.new
  attribute :custom_app_host, HostnameType.new
  attribute :custom_api_host, HostnameType.new
  attribute :logo
  attribute :favicon
  attribute :webhook_url
  attribute :enable_webhooks, :boolean, default: true

  delegate :persisted?, :id, to: :carrier

  validates :name, presence: true
  validates :country, inclusion: { in: COUNTRIES }
  validates :website, presence: true, url_format: { allow_http: true, allow_blank: true }
  validates :webhook_url, url_format: { allow_http: true }, allow_blank: true
  validates :subdomain, presence: true,
                        subdomain: { scope: ->(form) { Carrier.where.not(id: form.carrier.id) } }

  validates :custom_app_host,
            :custom_api_host,
            hostname: { scope: ->(form) { Carrier.where.not(id: form.carrier.id) } }

  validates :custom_api_host, comparison: { other_than: :custom_app_host, allow_blank: true }

  def self.model_name
    ActiveModel::Name.new(self, nil, "CarrierSettings")
  end

  def self.initialize_with(carrier)
    new(
      carrier:,
      name: carrier.name,
      subdomain: carrier.subdomain,
      website: carrier.website,
      country: carrier.country_code,
      logo: carrier.logo,
      favicon: carrier.favicon,
      webhook_url: carrier.webhook_endpoint&.url,
      enable_webhooks: carrier.webhooks_enabled?,
      custom_app_host: carrier.custom_app_host,
      custom_api_host: carrier.custom_api_host
    )
  end

  def save
    return false if invalid?

    carrier.attributes = {
      name:,
      website:,
      subdomain:,
      custom_app_host:,
      custom_api_host:,
      country_code: country
    }

    webhook_endpoint.enabled = enable_webhooks
    webhook_endpoint.url = webhook_url if webhook_url.present?

    carrier.logo.attach(logo) if logo.present?
    carrier.favicon.attach(favicon) if favicon.present?

    Carrier.transaction do
      carrier.save!
      webhook_endpoint.save! if update_webhook_endpoint?
    end

    true
  end

  def webhook_configured?
    carrier.webhook_endpoint.present?
  end

  def webhooks_disabled?
    webhook_configured? && !carrier.webhook_endpoint.enabled?
  end

  private

  def webhook_endpoint
    @webhook_endpoint ||= carrier.webhook_endpoint || WebhookEndpoint.new(
      oauth_application: carrier.oauth_application
    )
  end

  def update_webhook_endpoint?
    webhook_configured? || webhook_url.present?
  end
end
