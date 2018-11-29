module Twilio
  module APIError
    class Unauthorized < Base
      DEFAULT_CODE = 20003
      DEFAULT_DETAIL = "Your AccountSid or AuthToken was incorrect."
      DEFAULT_MESSAGE = "Authentication Error - invalid username"
      DEFAULT_STATUS = 401

      def self.default_code
        DEFAULT_CODE
      end

      def self.default_detail
        DEFAULT_DETAIL
      end

      def self.default_message
        DEFAULT_MESSAGE
      end

      def self.default_status
        DEFAULT_STATUS
      end
    end
  end
end
