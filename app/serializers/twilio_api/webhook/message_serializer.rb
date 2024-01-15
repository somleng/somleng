module TwilioAPI
  module Webhook
    class MessageSerializer < TwilioAPISerializer
      # https://www.twilio.com/docs/messaging/guides/webhook-request

      # | Parameter           | Description                                                                                                     |
      # |---------------------|-----------------------------------------------------------------------------------------------------------------|
      # | MessageSid          | A 34 character unique identifier for the message. May be used to later retrieve this message from the REST API. |
      # | AccountSid          | Your Twilio account ID.                                                                                         |
      # | MessagingServiceSid | The 34 character id of the Messaging Service associated with the message.                                       |
      # | From                | The phone number or Channel address that sent this message.                                                     |
      # | To                  | The phone number or Channel address of the recipient.                                                           |
      # | Body                | The text body of the message. Up to 1600 characters long.                                                       |
      # | NumMedia            | The number of media items associated with your message                                                          |
      # | ReferralNumMedia    | The number of media items associated with a "Click to WhatsApp" advertisement.                                  |
      # | ApiVersion          | The version of the Twilio API used to handle this call.                                                         |

      def attributes
        super.merge(
          "MessageSid" => nil,
          "AccountSid" => nil,
          "MessagingServiceSid" => nil,
          "From" => nil,
          "To" => nil,
          "Body" => nil,
          "NumMedia" => nil,
          "ReferralNumMedia" => nil,
          "ApiVersion" => nil
        )
      end

      def serializable_hash(options = nil)
        super.compact
      end

      def MessageSid
        sid
      end

      def AccountSid
        account_sid
      end

      def MessagingServiceSid
        messaging_service_id
      end

      def From
        object.from
      end

      def To
        object.to
      end

      def Body
        body
      end

      def NumMedia
        0
      end

      def ReferralNumMedia
        0
      end

      def ApiVersion
        TwilioAPI::ResourceSerializer::API_VERSION
      end
    end
  end
end
