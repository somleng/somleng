module TwilioAPI
  module Verify
    class VerificationSerializer < ResourceSerializer
      def attributes
        super.merge(
          service_sid: nil,
          to: nil,
          channel: nil,
          status: nil,
          url: nil
        )
      end

      def service_sid
        object.verification_service_id
      end

      def url
        url_helpers.api_twilio_verify_service_verification_url(
          object.verification_service, object,
          format: :json
        )
      end
    end
  end
end
