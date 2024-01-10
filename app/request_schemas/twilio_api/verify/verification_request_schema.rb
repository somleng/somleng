module TwilioAPI
  module Verify
    class VerificationRequestSchema < TwilioAPIRequestSchema
      option :verification_service
      option :phone_number_validator, default: proc { PhoneNumberValidator.new }

      params do
        required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
        required(:Channel).filled(:str?, included_in?: Verification.channel.values)
      end

      rule(:To) do
        key.failure("is invalid") unless phone_number_validator.valid?(value)
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
