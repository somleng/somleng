module TwilioAPI
  module Verify
    class VerificationServiceSerializer < ResourceSerializer
      def attributes
        super.merge(
          friendly_name: nil,
          url: nil,
          code_length: nil
        )
      end

      def friendly_name
        name
      end

      def url
        url_helpers.api_twilio_verify_verification_service_url(object, format: :json)
      end

      private

      def collection_name
        "services"
      end
    end
  end
end
