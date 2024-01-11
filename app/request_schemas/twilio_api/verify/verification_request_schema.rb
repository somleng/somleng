module TwilioAPI
  module Verify
    class VerificationRequestSchema < TwilioAPIRequestSchema
      option :verification_service
      option :verifications_scope
      option :phone_number_validator, default: -> { PhoneNumberValidator.new }
      option :phone_number_configuration_rules,
             default: -> { PhoneNumberConfigurationRules.new }
      option :sms_gateway_resolver,
             default: -> { SMSGatewayResolver.new }

      params do
        required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
        required(:Channel).filled(:str?, included_in?: Verification.channel.values)
      end

      rule(:To) do
        key.failure("is invalid") unless phone_number_validator.valid?(value)
      end

      rule(:To, :Channel) do
        if values[:Channel] == "sms"
          sms_gateway, _channel = sms_gateway_resolver.resolve(
            carrier: account.carrier,
            destination: values[:To]
          )

          next if sms_gateway.present?

          base.failure(schema_helper.build_schema_error(:unreachable_carrier))
        end
      end

      rule(:To) do |context:|
        context[:verification] = verifications_scope.find_by(to: value)
        next if context[:verification].blank?
        next unless context[:verification].max_delivery_attempts_reached?

        base.failure(schema_helper.build_schema_error(:max_send_attempts_reached))
      end

      rule do |context:|
        context[:phone_number] = verification_service.account.phone_numbers.first
        next if phone_number_configuration_rules.valid?(phone_number: context[:phone_number])

        base.failure(schema_helper.build_schema_error(:verify_could_not_find_valid_phone_number))
      end

      def output
        params = super

        {
          verification_service:,
          verification: context[:verification],
          account: verification_service.account,
          carrier: verification_service.carrier,
          channel: params.fetch(:Channel),
          to: params.fetch(:To),
          delivery_attempt: {
            from: context.fetch(:phone_number).number
          }
        }.compact
      end
    end
  end
end
