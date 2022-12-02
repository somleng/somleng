# frozen_string_literal: true

module TwilioAPI
  module Errors
    class TwilioError < StandardError
      attr_reader :code

      def initialize(message = self.class::MESSAGE, code: self.class::CODE)
        super(message)
        @code = code
      end
    end

    class MessagingServiceBlankError < TwilioError
      MESSAGE = "The Messaging Service does not exist"
      CODE = "21701"
    end

    class MessagingServiceNoSendersAvailableError < TwilioError
      MESSAGE = "The Messaging Service does not have a phone number available to send a message"
      CODE = "21703"
    end

    class MessagingServiceNoSendersError < TwilioError
      MESSAGE = "The Messaging Service contains no phone numbers"
      CODE = "21704"
    end

    class UnreachableCarrierError < TwilioError
      MESSAGE = "Landline or unreachable carrier"
      CODE = "30006"
    end

    class MessageIncapablePhoneNumberError < TwilioError
      MESSAGE = "The 'From' phone number provided is not a valid message-capable phone number for this destination."
      CODE = "21606"
    end

    class SentAtMissingError < TwilioError
      MESSAGE = "SendAt cannot be empty for ScheduleType 'fixed'"
      CODE = "35111"
    end

    class ScheduledMessageMessagingServiceSidMissingError < TwilioError
      MESSAGE = "MessagingServiceSid is required to schedule a message"
      CODE = "35118"
    end

    class SendAtInvalidError < TwilioError
      MESSAGE = "SendAt time must be between 900 seconds and 7 days (604800 seconds) in the future"
      CODE = "35114"
    end
  end
end
