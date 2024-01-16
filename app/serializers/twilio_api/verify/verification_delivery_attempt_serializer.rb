module TwilioAPI
  module Verify
    class VerificationDeliveryAttemptSerializer < ApplicationSerializer
      def attributes
        super.merge(
          attempt_sid: nil,
          channel: nil,
          time: nil
        )
      end

      def attempt_sid
        id
      end

      def time
        created_at.utc.iso8601
      end
    end
  end
end
