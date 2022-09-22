module Services
  class InboundPhoneCallRequestSchema < ServicesRequestSchema
    option(:error_log_messages)

    params do
      required(:to).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:from).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:source_ip).filled(:str?)
      required(:external_id).filled(:str?)
      optional(:client_identifier).maybe(:str?)
      optional(:variables).maybe(:hash)
    end

    rule(:client_identifier, :source_ip) do |context:|
      if values[:client_identifier].present?
        source_identity = values.fetch(:client_identifier)
        context[:sip_trunk] = SIPTrunk.find_by(username: source_identity)
      else
        source_identity = values.fetch(:source_ip)
        context[:sip_trunk] = SIPTrunk.find_by(inbound_source_ip: source_identity)
      end

      if context[:sip_trunk].blank?
        base.failure("#{source_identity} doesn't exist")
        error_log_messages << "SIP trunk does not exist for #{source_identity}"
      end
    end

    rule(:to) do |context:|
      next if context[:sip_trunk].blank?

      phone_numbers = context[:sip_trunk].carrier.phone_numbers
      context[:phone_number] = phone_numbers.find_by(number: value)

      if context[:phone_number].blank?
        key.failure("doesn't exist")
        error_log_messages << "Phone number #{value} does not exist"
      elsif !context[:phone_number].assigned?
        key.failure("is unassigned")
        error_log_messages << "Phone number #{value} is unassigned"
      elsif !context[:phone_number].configured?
        key.failure("is unconfigured")
        error_log_messages << "Phone number #{value} is unconfigured"
      elsif !context[:phone_number].enabled?
        key.failure("is disabled")
        error_log_messages << "Phone number #{value} is disabled"
      end
    end

    rule(:from) do |context:|
      next if context[:sip_trunk].blank?

      context[:from] = normalize_from(value, context[:sip_trunk].inbound_trunk_prefix_replacement)
      unless Phony.plausible?(context[:from])
        key.failure(
          "is invalid. It must be an E.164 formatted phone number and must include the country code"
        )
        error_log_messages << "From #{value} is invalid. It must be an E.164 formatted phone number and must include the country code"
      end
    end

    rule do |context:|
      error_log_messages.carrier = context[:sip_trunk]&.carrier
      error_log_messages.account = context[:phone_number]&.account

      next if context[:phone_number].blank?
      next if CarrierStanding.new(context[:phone_number].carrier).good_standing?

      base.failure("carrier is not in good standing")
      error_log_messages << "Carrier is not in good standing"
    end

    def output
      params = super

      result = {}
      result[:to] = params.fetch(:to)
      result[:external_id] = params.fetch(:external_id)
      result[:variables] = params.fetch(:variables) if params.key?(:variables)

      phone_number = context.fetch(:phone_number)
      result[:phone_number] = phone_number
      result[:sip_trunk] = context.fetch(:sip_trunk)
      result[:direction] = :inbound
      result[:account] = phone_number.account
      result[:carrier] = phone_number.carrier
      result[:voice_url] = phone_number.configuration.voice_url
      result[:voice_method] = phone_number.configuration.voice_method
      result[:status_callback_url] = phone_number.configuration.status_callback_url
      result[:status_callback_method] = phone_number.configuration.status_callback_method
      if phone_number.configuration.sip_domain.present?
        result[:twiml] =
          route_to_sip_domain(phone_number)
      end
      result[:from] = context[:from]

      result
    end

    private

    def normalize_from(from, trunk_prefix_replacement)
      result = from.sub(/\A\+*/, "")

      return result if trunk_prefix_replacement.blank?
      return result if result.starts_with?(trunk_prefix_replacement)

      result.sub(/\A(?:0)?/, "").prepend(trunk_prefix_replacement)
    end

    def route_to_sip_domain(phone_number)
      response = Twilio::TwiML::VoiceResponse.new
      response.dial do |dial|
        dial.sip("sip:#{phone_number.number}@#{phone_number.configuration.sip_domain}")
      end
      response.to_xml
    end
  end
end
