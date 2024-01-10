module TwilioAPI
  module Verify
    class UpdateVerificationServiceRequestSchema < TwilioAPIRequestSchema
      params do
        optional(:FriendlyName).filled(:str?, max_size?: 32)
        optional(:CodeLength).filled(:integer, gteq?: 4, lteq?: 10)
      end

      def output
        params = super

        result = {}
        result[:name] = params.fetch(:FriendlyName) if params[:FriendlyName].present?
        result[:code_length] = params.fetch(:CodeLength) if params[:CodeLength].present?

        result
      end
    end
  end
end
