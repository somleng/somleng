class InboundMessageBehavior
  attr_reader :phone_number

  delegate :configuration, to: :phone_number, allow_nil: true, private: true
  delegate :messaging_service, to: :configuration, allow_nil: true, private: true
  delegate :inbound_message_behavior, to: :messaging_service, allow_nil: true, private: true
  delegate :webhook?, :drop?,
           to: :inbound_message_behavior, allow_nil: true, private: true, prefix: :messaging_service
  delegate :inbound_request_url, :inbound_request_method,
           to: :messaging_service, allow_nil: true, private: true

  def initialize(phone_number)
    @phone_number = phone_number
  end

  def webhook_request
    return if messaging_service_drop?
    return [ inbound_request_url, inbound_request_method ] if messaging_service_webhook?

    [ configuration.sms_url, configuration.sms_method ]
  end

  def configured?
    return true if messaging_service_drop?
    return inbound_request_url.present? if messaging_service_webhook?

    configuration&.sms_url.present?
  end
end
