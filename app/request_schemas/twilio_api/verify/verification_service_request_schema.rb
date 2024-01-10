module TwilioAPI
  module Verify
    class VerificationServiceRequestSchema < TwilioAPIRequestSchema
      params do
        required(:FriendlyName).filled(:str?, max_size?: 32)
        optional(:CodeLength).filled(:integer, gteq?: 4, lteq?: 10)
      end

      def output
        params = super

        {
          account:,
          carrier: account.carrier,
          name: params.fetch(:FriendlyName),
          code_length: params.fetch(:CodeLength, 4)
        }
      end
    end
  end
end
