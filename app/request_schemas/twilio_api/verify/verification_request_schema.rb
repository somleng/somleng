module TwilioAPI
  module Verify
    class VerificationRequestSchema < TwilioAPIRequestSchema
      option :verification_service
      option :verifications_scope
      option :phone_number_validator, default: -> { PhoneNumberValidator.new }
      option :phone_number_configuration_rules,
             default: -> { PhoneNumberConfigurationRules.new }
      option :message_destination_schema_rules,
             default: -> { MessageDestinationSchemaRules.new }
      option :phone_call_destination_schema_rules,
             default: -> { PhoneCallDestinationSchemaRules.new }

      params do
        required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
        required(:Channel).filled(:str?, included_in?: Verification.channel.values)
      end

      rule(:To) do
        key.failure("is invalid") unless phone_number_validator.valid?(value)
      end

      rule(:To, :Channel) do
        if values[:Channel] == "sms"
          message_destination_schema_rules.carrier = account.carrier
          message_destination_schema_rules.destination = values[:To]

          unless message_destination_schema_rules.valid?
            base.failure(schema_helper.build_schema_error(message_destination_schema_rules.error_code))
          end
        elsif values[:Channel] == "call"
          phone_call_destination_schema_rules.account = account
          phone_call_destination_schema_rules.destination = values[:To]

          unless phone_call_destination_schema_rules.valid?
            base.failure(schema_helper.build_schema_error(phone_call_destination_schema_rules.error_code))
          end
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
