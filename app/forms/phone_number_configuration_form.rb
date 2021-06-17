class PhoneNumberConfigurationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/.freeze

  attribute :voice_url
  attribute :voice_method
  attribute :status_callback_url
  attribute :status_callback_method
  attribute :phone_number

  validates :voice_url, presence: true
  validates :voice_url, format: URL_FORMAT, allow_nil: true, allow_blank: true
  validates :status_callback_url, format: URL_FORMAT, allow_nil: true, allow_blank: true
  validates :voice_method, presence: true, inclusion: { in: PhoneNumber.voice_method.values }
  validates :status_callback_method,
            inclusion: { in: PhoneNumber.status_callback_method.values },
            allow_blank: true, allow_nil: true

  delegate :persisted?, :new_record?, :id, to: :phone_number

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumberConfiguration")
  end

  def self.initialize_with(phone_number)
    new(
      phone_number: phone_number,
      voice_url: phone_number.voice_url,
      voice_method: phone_number.voice_method,
      status_callback_url: phone_number.status_callback_url,
      status_callback_method: phone_number.status_callback_method
    )
  end

  def save
    return false if invalid?

    phone_number.voice_url = voice_url
    phone_number.voice_method = voice_method
    phone_number.status_callback_url = status_callback_url.presence
    phone_number.status_callback_method = status_callback_method.presence

    phone_number.save!
  end
end
