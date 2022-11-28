module TwilioAPI
  class MessageRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: proc { PhoneNumberValidator.new }
    option :phone_number_configuration_rules,
           default: -> { PhoneNumberConfigurationRules.new }
    option :sms_encoding,
           default: -> { SMSEncoding.new }
    option :smart_encoding,
           default: -> { SmartEncoding.new }
    option :sms_gateway_resolver,
           default: -> { SMSGatewayResolver.new }

    params do
      required(:From).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:Body).filled(:string)
      optional(:StatusCallback).maybe(:string, format?: URL_FORMAT)
      optional(:StatusCallbackMethod).maybe(
        ApplicationRequestSchema::Types::UppercaseString,
        included_in?: Message.status_callback_method.values
      )
      optional(:ValidityPeriod).maybe(:integer, gteq?: 1, lteq?: 14_400)
      optional(:SmartEncoded).maybe(:bool)
    end

    rule(:To) do |context:|
      next key.failure("is invalid") unless phone_number_validator.valid?(value)

      sms_gateway, channel = sms_gateway_resolver.resolve(
        carrier: account.carrier,
        destination: value
      )

      if sms_gateway.blank?
        next base.failure(
          text: "Landline or unreachable carrier",
          code: "30006"
        )
      end

      context[:sms_gateway] = sms_gateway
      context[:channel] = channel
    end

    rule(:From) do |context:|
      context[:phone_number] = account.phone_numbers.find_by(number: value)

      next if phone_number_configuration_rules.valid?(phone_number: context[:phone_number])

      base.failure(
        text: "The 'From' phone number provided is not a valid message-capable phone number for this destination.",
        code: "21606"
      )
    end

    def output
      params = super

      body = params.fetch(:Body)
      body = smart_encoding.encode(body) if params[:SmartEncoded]
      encoding_result = sms_encoding.detect(body)

      {
        account:,
        carrier: account.carrier,
        phone_number: context.fetch(:phone_number),
        sms_gateway: context.fetch(:sms_gateway),
        channel: context.fetch(:channel),
        body:,
        segments: encoding_result.segments,
        encoding: encoding_result.encoding,
        to: params.fetch(:To),
        from: params.fetch(:From),
        status_callback_url: params[:StatusCallback],
        status_callback_method: params[:StatusCallbackMethod],
        direction: :outbound_api,
        validity_period: params[:ValidityPeriod]
      }
    end
  end
end
