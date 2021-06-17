class InboundPhoneCallRequestSchema < ApplicationRequestSchema
  params do
    required(:to).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
    required(:from).filled(:str?)
    required(:external_id).filled(:str?)
    optional(:variables).maybe(:hash)
  end

  rule(:to) do
    phone_number = find_phone_number(value)
    key("to").failure("does not exist") if phone_number.blank?
  end

  def output
    params = super

    result = {}
    result[:to] = params.fetch(:to)
    result[:external_id] = params.fetch(:external_id)
    result[:variables] = params.fetch(:variables) if params.key?(:variables)

    phone_number = find_phone_number(result.fetch(:to))
    result[:phone_number] = phone_number
    result[:direction] = :inbound
    result[:account] = phone_number.account
    result[:voice_url] = phone_number.voice_url
    result[:voice_method] = phone_number.voice_method
    result[:status_callback_url] = phone_number.status_callback_url
    result[:status_callback_method] = phone_number.status_callback_method
    result[:from] = normalize_from(
      params.fetch(:from),
      phone_number.account.settings["trunk_prefix_replacement"]
    )

    result
  end

  private

  def find_phone_number(phone_number)
    PhoneNumber.find_by(number: phone_number)
  end

  def normalize_from(from, trunk_prefix_replacement)
    result = from.sub(/\A\+*/, "")

    return result if trunk_prefix_replacement.blank?
    return result if result.starts_with?(trunk_prefix_replacement)

    result.sub(/\A(?:0)?/, "").prepend(trunk_prefix_replacement)
  end
end
