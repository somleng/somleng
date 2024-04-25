class InboundMessageBehavior
  attr_reader :incoming_phone_number

  delegate :messaging_service, to: :incoming_phone_number, allow_nil: true, private: true
  delegate :inbound_message_behavior, to: :messaging_service, allow_nil: true, private: true
  delegate :webhook?, :drop?,
           to: :inbound_message_behavior, allow_nil: true, private: true, prefix: :messaging_service
  delegate :inbound_request_url, :inbound_request_method,
           to: :messaging_service, allow_nil: true, private: true

  def initialize(incoming_phone_number)
    @incoming_phone_number = incoming_phone_number
  end

  def webhook_request
    return if messaging_service_drop?
    return [ inbound_request_url, inbound_request_method ] if messaging_service_webhook?

    [ incoming_phone_number.sms_url, incoming_phone_number.sms_method ]
  end

  def configured?
    return true if messaging_service_drop?
    return inbound_request_url.present? if messaging_service_webhook?

    incoming_phone_number.sms_url.present?
  end
end
