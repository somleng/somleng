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
        optional(:Locale).filled(:str?, included_in?: Verification.locale.values)
      end

      rule(:To) do
        key.failure("is invalid") unless phone_number_validator.valid?(value)
      end

      rule(:To, :Channel) do |context:|
        if values[:Channel] == "sms"
          message_destination_schema_rules.carrier = account.carrier
          message_destination_schema_rules.destination = values[:To]

          if message_destination_schema_rules.valid?
            context[:sender] = message_destination_schema_rules.sms_gateway.default_sender
          else
            base.failure(schema_helper.build_schema_error(message_destination_schema_rules.error_code))
          end
        elsif values[:Channel] == "call"
          phone_call_destination_schema_rules.account = account
          phone_call_destination_schema_rules.destination = values[:To]

          if phone_call_destination_schema_rules.valid?
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
        next if context[:sender]&.enabled?

        base.failure(schema_helper.build_schema_error(:verify_could_not_find_valid_phone_number))
      end

      def output
        params = super

        country, locale = resolve_locale(params)

        {
          verification_service:,
          verification: context[:verification],
          account: verification_service.account,
          carrier: verification_service.carrier,
          channel: params.fetch(:Channel),
          to: params.fetch(:To),
          country_code: country.alpha2,
          locale:,
          delivery_attempt: {
            phone_number: context.fetch(:sender),
            from: context.fetch(:sender).number
          }
        }.compact
      end

      private

      def resolve_locale(params)
        beneficiary_country = ResolvePhoneNumberCountry.call(
          params.fetch(:To),
          fallback_country: verification_service.carrier
        )
        locale = params.fetch(:Locale) do
          VerificationLocales.find_by_country(beneficiary_country).locale
        end

        [ beneficiary_country, locale ]
      end
    end
  end
end
