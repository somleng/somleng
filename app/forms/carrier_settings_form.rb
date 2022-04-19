class CarrierSettingsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[https])}\z/

  attribute :carrier
  attribute :name
  attribute :country
  attribute :logo
  attribute :webhook_url
  attribute :enable_webhooks, :boolean, default: true

  delegate :persisted?, :id, to: :carrier

  validates :name, presence: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }
  validates :webhook_url, format: URL_FORMAT, allow_blank: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "CarrierSettings")
  end

  def self.initialize_with(carrier)
    new(
      carrier:,
      name: carrier.name,
      country: carrier.country_code,
      logo: carrier.logo,
      webhook_url: carrier.webhook_endpoint&.url,
      enable_webhooks: carrier.webhooks_enabled?
    )
  end

  def save
    return false if invalid?

    carrier.attributes = {
      name:,
      country_code: country
    }

    webhook_endpoint.enabled = enable_webhooks
    webhook_endpoint.url = webhook_url if webhook_url.present?

    carrier.logo.attach(logo) if logo.present?

    Carrier.transaction do
      carrier.save!
      webhook_endpoint.save! if update_webhook_endpoint?
    end
  end

  def webhook_configured?
    carrier.webhook_endpoint.present?
  end

  def webhooks_disabled?
    webhook_configured? && !carrier.webhook_endpoint.enabled?
  end

  private

  def webhook_endpoint
    @webhook_endpoint ||= carrier.webhook_endpoint || WebhookEndpoint.new(oauth_application: carrier.oauth_application)
  end

  def update_webhook_endpoint?
    webhook_configured? || webhook_url.present?
  end
end
