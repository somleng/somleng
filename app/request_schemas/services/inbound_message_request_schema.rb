module Services
  class InboundMessageRequestSchema < ServicesRequestSchema
    option :phone_number_validator, default: -> { PhoneNumberValidator.new }
    option :phone_number_configuration_rules,
           default: -> { PhoneNumberConfigurationRules.new }
    option :inbound_message_behavior,
           default: -> { ->(phone_number) { InboundMessageBehavior.new(phone_number) } }

    option :sms_encoding, default: -> { SMSEncoding.new }
    option :sms_gateway
    option :error_log_messages

    params do
      required(:from).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:to).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:body).maybe(:string)
    end

    rule(:to) do |context:|
      next unless key?

      context[:incoming_phone_number] = sms_gateway.carrier.incoming_phone_numbers.active.find_by(number: value)

      next if phone_number_configuration_rules.valid?(context[:incoming_phone_number]) do
        InboundMessageBehavior.new(context[:incoming_phone_number]).configured?
      end

      error_message = format(phone_number_configuration_rules.error_message, value:)
      base.failure(error_message)

      error_log_messages << error_message
    end

    rule do
      next if CarrierStanding.new(sms_gateway.carrier).good_standing?

      error = schema_helper.fetch_error(:carrier_standing)
      base.failure(text: error.message, code: error.code)
      error_log_messages << error.message
    end

    rule do |context:|
      error_log_messages.carrier = sms_gateway.carrier
      error_log_messages.account = context[:phone_number]&.account
    end

    def output
      params = super
      incoming_phone_number = context.fetch(:incoming_phone_number)
      body = params.fetch(:body)
      encoding_result = sms_encoding.detect(body)

      request_url, request_method = inbound_message_behavior.call(incoming_phone_number).webhook_request

      {
        account: incoming_phone_number.account,
        carrier: sms_gateway.carrier,
        sms_gateway:,
        incoming_phone_number:,
        phone_number: incoming_phone_number.phone_number,
        messaging_service: incoming_phone_number.messaging_service,
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
