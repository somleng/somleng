class PhoneNumberConfigurationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/.freeze

  attribute :voice_url
  attribute :voice_method
  attribute :status_callback_url
  attribute :status_callback_method
  attribute :sip_domain
  attribute :phone_number_configuration

  validates :voice_url, format: URL_FORMAT, allow_blank: true
  validates :status_callback_url, format: URL_FORMAT, allow_blank: true
  validates :voice_method,
            inclusion: { in: PhoneNumberConfiguration.voice_method.values },
            allow_blank: true
  validates :status_callback_method,
            inclusion: { in: PhoneNumberConfiguration.status_callback_method.values },
            allow_blank: true

  def persisted?
    true
  end

  def phone_number
    phone_number_configuration.phone_number
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumberConfiguration")
  end

  def self.initialize_with(phone_number_configuration)
    new(
      phone_number_configuration:,
      voice_url: phone_number_configuration.voice_url,
      voice_method: phone_number_configuration.voice_method,
      status_callback_url: phone_number_configuration.status_callback_url,
      status_callback_method: phone_number_configuration.status_callback_method,
      sip_domain: phone_number_configuration.sip_domain
    )
  end

  def save
    return false if invalid?

    phone_number_configuration.update!(
      voice_url: voice_url.presence,
      voice_method: voice_method.presence,
      status_callback_url: status_callback_url.presence,
      status_callback_method: status_callback_method.presence,
      sip_domain: sip_domain.presence
    )
  end
end
