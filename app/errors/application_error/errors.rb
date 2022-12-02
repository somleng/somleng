module ApplicationError
  module Errors
    Error = Struct.new(:message, :code, keyword_init: true)

    ERRORS = {
      messaging_service_blank: Error.new(code: "21701", message: "The Messaging Service does not exist"),
      messaging_service_no_senders_available: Error.new(code: "21703", message: "The Messaging Service does not have a phone number available to send a message"),
      messaging_service_no_senders: Error.new(code: "21704", message: "The Messaging Service contains no phone numbers"),
      unreachable_carrier: Error.new(code: "30006", message:  "Landline or unreachable carrier"),
      message_incapable_phone_number: Error.new(code: "21606", message: "The 'From' phone number provided is not a valid message-capable phone number for this destination."),
      sent_at_missing: Error.new(code: "35111", message: "SendAt cannot be empty for ScheduleType 'fixed'"),
      scheduled_message_messaging_service_sid_missing: Error.new(code: "35118", message: "MessagingServiceSid is required to schedule a message"),
      send_at_invalid: Error.new(code: "35114", message: "SendAt time must be between 900 seconds and 7 days (604800 seconds) in the future"),
      validity_period_expired: Error.new(code: "S1001", message: "Validity period expired"),
      sms_gateway_disconnected: Error.new(code: "S1002", message: "SMS Gateway disconnected")
    }.freeze

    def self.fetch(error)
      ERRORS.fetch(error)
    end
  end
end
