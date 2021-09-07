module Services
  class InboundPhoneCallRequestSchema < ServicesRequestSchema
    params do
      required(:to).value(ApplicationRequestSchema::Types::PhoneNumber, :filled?)
      required(:source_ip).filled(:str?)
      required(:from).filled(:str?)
      required(:external_id).filled(:str?)
      optional(:variables).maybe(:hash)
    end

    rule(:source_ip) do |context:|
      context[:inbound_sip_trunk] = InboundSIPTrunk.find_by(source_ip: value)
      base.failure("Inbound SIP trunk does not exist for #{value}") if context[:inbound_sip_trunk].blank?
    end

    rule(:to) do |context:|
      if context[:inbound_sip_trunk].present?
        context[:phone_number] = context[:inbound_sip_trunk].carrier.phone_numbers.find_by(number: value)
        if context[:phone_number].present?
          base.failure("Account is unassigned") if context[:phone_number].account.blank?
        else
          base.failure("Phone number does not exist")
        end
      end
    end

    rule do |context:|
      if context[:phone_number].present?
        base.failure("Voice URL is not configured") if context[:phone_number].voice_url.blank?
      end
    end

    def output
      return {} if context[:inbound_sip_trunk].blank?

      params = super
      result = {}
      result[:to] = params.fetch(:to)
      result[:external_id] = params.fetch(:external_id)
      result[:variables] = params.fetch(:variables) if params.key?(:variables)

      phone_number = context.fetch(:phone_number)
      result[:phone_number] = phone_number
      result[:inbound_sip_trunk] = context.fetch(:inbound_sip_trunk)
      result[:direction] = :inbound
      result[:account] = phone_number.account
      result[:carrier] = phone_number.carrier
      result[:voice_url] = phone_number.voice_url
      result[:voice_method] = phone_number.voice_method || "POST"
      result[:status_callback_url] = phone_number.status_callback_url
      result[:status_callback_method] = phone_number.status_callback_method
      result[:twiml] = route_to_sip_domain(phone_number) if phone_number.sip_domain.present?
      result[:from] = normalize_from(
        params.fetch(:from),
        result[:inbound_sip_trunk].trunk_prefix_replacement
      )

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
        dial.sip("sip:#{phone_number.number}@#{phone_number.sip_domain}")
      end
      response.to_xml
    end
  end
end
