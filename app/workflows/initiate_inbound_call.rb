class InitiateInboundCall < ApplicationWorkflow
  ATTRIBUTE_MAPPINGS = {
    To: :to,
    From: :from,
    ExternalSid: :external_id,
    Variables: :variables
  }.freeze

  attr_accessor :attributes

  def initialize(attributes)
    self.attributes = attributes
  end

  def call
    phone_call = build_phone_call
    phone_call.initiate!
    phone_call
  end

  private

  def build_phone_call
    phone_call = PhoneCall.new(normalize_attributes)
    incoming_phone_number = IncomingPhoneNumber.find_by_phone_number(phone_call.to)
    return phone_call if incoming_phone_number.blank?

    phone_call.incoming_phone_number = incoming_phone_number
    phone_call.account = incoming_phone_number.account
    phone_call.attributes = incoming_phone_number.attributes.slice(
      "voice_url", "voice_method", "status_callback_url", "status_callback_method"
    )
    phone_call.twilio_request_to = incoming_phone_number.twilio_request_phone_number
    phone_call
  end

  def normalize_attributes
    attrs = attributes.transform_keys { |k| ATTRIBUTE_MAPPINGS.fetch(k) }
    original_from = attrs.fetch(:from)
    sip_host = SIPHost.find(attrs.dig(:variables, "sip_network_ip"))
    attrs[:from] = normalize_phone_number(original_from, sip_host)
    attrs
  end

  def normalize_phone_number(phone_number, number_config)
    return phone_number unless phone_number.starts_with?("0")
    return phone_number if number_config.blank?

    phone_number.sub(/\A0/, number_config.international_dialing_code)
  end
end
