module TwilioAPI
  module Verify
    class ServiceRequestSchema < TwilioAPIRequestSchema
      params do
        required(:FriendlyName).filled(:str?, max_size?: VerificationService::MAX_NAME_LENGTH)
        optional(:CodeLength).filled(
          :integer,
          gteq?: VerificationService::VALID_CODE_LENGTHS.min,
          lteq?: VerificationService::VALID_CODE_LENGTHS.max
        )
      end

      def output
        params = super

        {
          account:,
          carrier: account.carrier,
          name: params.fetch(:FriendlyName),
          code_length: params.fetch(:CodeLength, VerificationService::DEFAULT_CODE_LENGTH)
        }
      end
    end
  end
end
