module TwilioAPI
  module Verify
    class VerificationRequestSchema < TwilioAPIRequestSchema
      option :verification_service
      option :verifications_scope
      option :phone_number_validator, default: proc { PhoneNumberValidator.new }

      params do
        required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
        required(:Channel).filled(:str?, included_in?: Verification.channel.values)
      end

      rule(:To) do
        key.failure("is invalid") unless phone_number_validator.valid?(value)
      end

      rule(:To) do
        next unless verifications_scope.exists?(to: value)

        base.failure(schema_helper.build_schema_error(:max_send_attempts_reached))
      end

      def output
        params = super

        {
          verification_service:,
          account: verification_service.account,
          carrier: verification_service.carrier,
          channel: params.fetch(:Channel),
          to: params.fetch(:To)
        }
      end
    end
  end
end
