module Services
  class InboundMessageRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: proc { PhoneNumberValidator.new }
    option :phone_number_configuration_rules,
           default: proc { PhoneNumberConfigurationRules.new }
    option :carrier_standing_rules,
           default: proc { CarrierStandingRules.new }
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

      {
        account: phone_number.account,
        carrier: sms_gateway.carrier,
        sms_gateway:,
        segments: 1,
        body: params.fetch(:body),
        to: params.fetch(:to),
        from: params.fetch(:from),
        status_callback_url: phone_number.status_callback_url,
        status_callback_method: phone_number.status_callback_method,
        direction: :inbound,
        status: :received
      }
    end
  end
end