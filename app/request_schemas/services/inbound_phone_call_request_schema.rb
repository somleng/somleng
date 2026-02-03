module Services
  class InboundPhoneCallRequestSchema < ServicesRequestSchema
    option :error_log_messages
    option :phone_number_validator, default: -> { PhoneNumberValidator.new }
    option :phone_number_configuration_rules,
           default: -> { PhoneNumberConfigurationRules.new }
    option :sip_trunk_resolver, default: -> { SIPTrunkResolver.new }

    params do
      required(:to).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:from).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:source_ip).filled(:str?)
      required(:external_id).filled(:str?)
      required(:host).filled(:str?)
      required(:region).filled(:str?, included_in?: SomlengRegion::Region.all.map(&:alias))
      optional(:client_identifier).maybe(:str?)
      optional(:variables).maybe(:hash)
    end

    rule(:client_identifier, :source_ip, :to) do |context:|
      if values[:client_identifier].present?
        source_identity = values.fetch(:client_identifier)
        context[:sip_trunk] = SIPTrunk.find_by(username: source_identity)
      else
        source_identity = values.fetch(:source_ip)
        context[:sip_trunk] = sip_trunk_resolver.find_sip_trunk_by(source_ip: source_identity, destination_number: values[:to])
      end

      if context[:sip_trunk].blank?
        base.failure("#{source_identity} doesn't exist")
        error_log_messages << "SIP trunk does not exist for #{source_identity}"
      end
    end

    rule(:to) do |context:|
      next if context[:sip_trunk].blank?

      context[:to] = context.fetch(:sip_trunk).normalize_number(value)
      incoming_phone_numbers = context[:sip_trunk].carrier.incoming_phone_numbers.active
      context[:incoming_phone_number] = incoming_phone_numbers.find_by(number: context[:to])
      next if phone_number_configuration_rules.valid?(context[:incoming_phone_number]) do
        context[:incoming_phone_number].voice_url.present?
      end

      error_message = format(phone_number_configuration_rules.error_message, value: context[:to])
      base.failure(error_message)
      error_log_messages << error_message
    end

    rule(:from) do |context:|
      next if context[:sip_trunk].blank?

      context[:from] = context.fetch(:sip_trunk).normalize_number(value)
      unless phone_number_validator.valid?(context[:from])
        key.failure(
          "is invalid. It must be an E.164 formatted phone number and must include the country code"
        )
        error_log_messages << "From #{context[:from]} is invalid. It must be an E.164 formatted phone number and must include the country code"
      end
    end

    rule do |context:|
      error_log_messages.carrier = context[:sip_trunk]&.carrier
      error_log_messages.account = context[:incoming_phone_number]&.account
    end

    rule do |context:|
      next if context[:incoming_phone_number].blank?
      next if CarrierStanding.new(context[:incoming_phone_number].carrier).good_standing?

      error = schema_helper.fetch_error(:carrier_standing)
      base.failure(text: error.message, code: error.code)
      error_log_messages << error.message
    end

    def output
      params = super

      result = {}
      result[:external_id] = params.fetch(:external_id)
      result[:variables] = params.fetch(:variables) if params.key?(:variables)

      incoming_phone_number = context.fetch(:incoming_phone_number)
      result[:incoming_phone_number] = incoming_phone_number
      result[:phone_number] = incoming_phone_number.phone_number
      result[:sip_trunk] = context.fetch(:sip_trunk)
      result[:direction] = :inbound
      result[:account] = incoming_phone_number.account
      result[:carrier] = incoming_phone_number.carrier
      result[:voice_url] = incoming_phone_number.voice_url
      result[:voice_method] = incoming_phone_number.voice_method
      result[:status_callback_url] = incoming_phone_number.status_callback_url
      result[:status_callback_method] = incoming_phone_number.status_callback_method
      result[:call_service_host] = params.fetch(:host)
      result[:region] = params.fetch(:region)
      if incoming_phone_number.sip_domain.present?
        result[:twiml] = route_to_sip_domain(incoming_phone_number)
      end
      result[:to] = context[:to]
      result[:from] = context[:from]

      result
    end

    private

    def route_to_sip_domain(incoming_phone_number)
      response = Twilio::TwiML::VoiceResponse.new
      response.dial do |dial|
        dial.sip(sip_url: "sip:#{incoming_phone_number.number}@#{incoming_phone_number.sip_domain}")
      end
      response.to_xml
    end
  end
end
