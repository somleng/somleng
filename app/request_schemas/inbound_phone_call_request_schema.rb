class InboundPhoneCallRequestSchema < ApplicationRequestSchema
  params do
    required(:To).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
    required(:From).filled(:str?)
    required(:ExternalSid).filled(:str?)
    optional(:Variables).maybe(:hash)
  end

  rule(:To) do
    incoming_phone_number = find_incoming_phone_number(value)
    key("To").failure("does not exist") if incoming_phone_number.blank?
  end

  def output
    params = super

    result = {}
    result[:to] = params.fetch(:To)
    result[:external_id] = params.fetch(:ExternalSid)
    result[:variables] = params.fetch(:Variables) if params.key?(:Variables)

    incoming_phone_number = find_incoming_phone_number(result.fetch(:to))
    result[:incoming_phone_number] = incoming_phone_number
    result[:account] = incoming_phone_number.account
    result[:voice_url] = incoming_phone_number.voice_url
    result[:voice_method] = incoming_phone_number.voice_method
    result[:status_callback_url] = incoming_phone_number.status_callback_url
    result[:status_callback_method] = incoming_phone_number.status_callback_method
    result[:twilio_request_to] = incoming_phone_number.twilio_request_phone_number
    result[:from] = normalize_from(
      params.fetch(:From),
      incoming_phone_number.account.settings["trunk_prefix_replacement"]
    )

    result
  end

  private

  def find_incoming_phone_number(phone_number)
    IncomingPhoneNumber.find_by(phone_number: phone_number)
  end

  def normalize_from(from, trunk_prefix_replacement)
    result = from.sub(/\A\+*/, "")

    return result if trunk_prefix_replacement.blank?
    return result if result.starts_with?(trunk_prefix_replacement)

    result.sub(/\A(?:0)?/, "").prepend(trunk_prefix_replacement)
  end
end
