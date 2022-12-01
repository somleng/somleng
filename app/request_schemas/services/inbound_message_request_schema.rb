module Services
  class InboundMessageRequestSchema < ServicesRequestSchema
    option :phone_number_validator, default: -> { PhoneNumberValidator.new }
    option :phone_number_configuration_rules,
           default: lambda {
             PhoneNumberConfigurationRules.new(
               configuration_context: ->(phone_number) { InboundMessageBehavior.new(phone_number) }
             )
           }
    option :inbound_message_behavior,
           default: -> { ->(phone_number) { InboundMessageBehavior.new(phone_number) } }

    option :carrier_standing_rules, default: -> { CarrierStandingRules.new }
    option :sms_encoding, default: -> { SMSEncoding.new }
    option :sms_gateway
    option :error_log_messages

    params do
      optional(:from).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:to).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:body).maybe(:string)
    end

    rule(:to) do |context:|
      next unless key?
      next key.failure("is invalid") unless phone_number_validator.valid?(value)

      context[:phone_number] = sms_gateway.carrier.phone_numbers.find_by(number: value)

      next if phone_number_configuration_rules.valid?(phone_number: context[:phone_number])
      if inbound_message_behavior.call(context[:phone_number]).drop?
        next base.failure("Message was dropped")
      end

      error_message = format(phone_number_configuration_rules.error_message, value:)
      base.failure(error_message)

      error_log_messages << error_message
    end

    rule do
      next if carrier_standing_rules.valid?(carrier: sms_gateway.carrier)

      base.failure(carrier_standing_rules.error_message)
      error_log_messages << carrier_standing_rules.error_message
    end

    rule do |context:|
      error_log_messages.carrier = sms_gateway.carrier
      error_log_messages.account = context[:phone_number]&.account
    end

    def output
      params = super
      phone_number = context.fetch(:phone_number)
      body = params.fetch(:body)
      encoding_result = sms_encoding.detect(body)

      request_url, request_method = inbound_message_behavior.call(phone_number).webhook_request

      {
        account: phone_number.account,
        carrier: sms_gateway.carrier,
        sms_gateway:,
        phone_number:,
        messaging_service: phone_number.configuration.messaging_service,
        segments: encoding_result.segments,
        encoding: encoding_result.encoding,
        body:,
        to: params.fetch(:to),
        from: params.fetch(:from),
        sms_url: request_url,
        sms_method: request_method,
        direction: :inbound,
        status: :received
      }
    end
  end
end
