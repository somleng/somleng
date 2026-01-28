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
             default: -> { SchemaRules::PhoneCallDestinationSchemaRules.new }

      params do
        required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
        required(:Channel).filled(:str?, included_in?: Verification.channel.values)
        optional(:Locale).filled(:str?, included_in?: Verification.locale.values)
      end

      rule(:To) do
        key.failure("is invalid") unless phone_number_validator.valid?(value)
      end

      rule(:To, :Channel) do |context:|
        if values[:Channel] == "sms"
          if message_destination_schema_rules.valid?(account:, destination: values[:To])
            sms_gateway, = message_destination_schema_rules.sms_gateway
            context[:sender] = sms_gateway.default_sender
          else
            base.failure(schema_helper.build_schema_error(message_destination_schema_rules.error_code))
          end
        elsif values[:Channel] == "call"
          if phone_call_destination_schema_rules.valid?(account:, destination: values[:To])
            context[:sender] = phone_call_destination_schema_rules.sip_trunk.default_sender
          else
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
        next if context[:sender].present?

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
          locale: params[:Locale],
          delivery_attempt: {
            from: context.fetch(:sender)
          }
        }.compact
      end
    end
  end
end
