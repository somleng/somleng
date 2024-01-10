module TwilioAPI
  module Verify
    class VerificationCheckSerializer < ResourceSerializer
      def attributes
        super.merge(
          service_sid: nil,
          to: nil,
          channel: nil,
          status: nil
        )
      end

      def service_sid
        object.verification_service_id
      end
    end
  end
end
