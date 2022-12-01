module TwilioAPI
  module Webhook
    class MessageStatusCallbackSerializer < MessageSerializer
      def attributes
        super.merge(
          "MessageStatus" => nil
        )
      end

      def serializable_hash(options = nil)
        super.compact
      end

      def MessageStatus
        status
      end
    end
  end
end
