class IncomingPhoneNumberForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :friendly_name
  attribute :voice_url
  attribute :voice_method
  attribute :status_callback_url
  attribute :status_callback_method
  attribute :sip_domain
  attribute :messaging_service_id
  attribute :sms_url
  attribute :sms_method
  attribute :incoming_phone_number, default: -> { IncomingPhoneNumber.new }

  validates :voice_url, :sms_url, url_format: { allow_http: true }, allow_blank: true
  validates :status_callback_url, url_format: { allow_http: true }, allow_blank: true
  validates :voice_method,
            inclusion: { in: IncomingPhoneNumber.voice_method.values },
            allow_blank: true
  validates :status_callback_method,
            inclusion: { in: IncomingPhoneNumber.status_callback_method.values },
            allow_blank: true
  validates :sms_method,
            inclusion: { in: IncomingPhoneNumber.sms_method.values },
            allow_blank: true

  delegate :persisted?, :new_record?, :id, to: :incoming_phone_number

  validates :friendly_name, presence: true, length: { maximum: 64 }

  def self.model_name
    ActiveModel::Name.new(self, nil, "IncomingPhoneNumber")
  end

  def self.initialize_with(incoming_phone_number)
    new(
      incoming_phone_number:,
      friendly_name: incoming_phone_number.friendly_name,
      voice_url: incoming_phone_number.voice_url,
      voice_method: incoming_phone_number.voice_method,
      status_callback_url: incoming_phone_number.status_callback_url,
      status_callback_method: incoming_phone_number.status_callback_method,
      sip_domain: incoming_phone_number.sip_domain,
      sms_url: incoming_phone_number.sms_url,
      sms_method: incoming_phone_number.sms_method,
      messaging_service_id: incoming_phone_number.messaging_service_id
    )
  end

  def save
    return false if invalid?

    incoming_phone_number.update!(
      friendly_name:,
      voice_url: voice_url.presence,
      voice_method: voice_method.presence,
      status_callback_url: status_callback_url.presence,
      status_callback_method: status_callback_method.presence,
      sip_domain: sip_domain.presence,
      sms_url: sms_url.presence,
      sms_method: sms_method.presence,
      messaging_service: find_messaging_service
    )
  end

  def messaging_service_options_for_select
    messaging_services
  end

  private

  def messaging_services
    incoming_phone_number.account.messaging_services
  end

  def find_messaging_service
    return if messaging_service_id.blank?

    messaging_services.find(messaging_service_id)
  end
end
