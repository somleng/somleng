module TwilioAPI
  module Verify
    class ServiceSerializer < ResourceSerializer
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
        url_helpers.api_twilio_verify_service_url(object, format: :json)
      end
    end
  end
end
