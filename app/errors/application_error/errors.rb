module ApplicationError
  module Errors
    Error = Struct.new(:message, :code, keyword_init: true)

    ERRORS = {
      validity_period_expired: Error.new(code: "S1001", message: "Validity period expired"),
      sms_gateway_disconnected: Error.new(code: "S1002", message: "SMS Gateway disconnected"),
      update_before_complete: Error.new(
        code: "S1003",
        message: "Cannot update this resource before it is complete"
      ),
      carrier_standing: Error.new(code: "S1004", message: "Carrier is not in good standing"),
      account_suspended: Error.new(code: "30002", message: "Account suspended"),
      messaging_service_blank: Error.new(
        code: "21701",
        message: "The Messaging Service does not exist"
      ),
      messaging_service_no_senders_available: Error.new(
        code: "21703",
        message: "The Messaging Service does not have a phone number available to send a message"
      ),
      messaging_service_no_senders: Error.new(
        code: "21704",
        message: "The Messaging Service contains no phone numbers"
      ),
      unreachable_carrier: Error.new(code: "30006", message: "Landline or unreachable carrier"),
      message_incapable_phone_number: Error.new(
        code: "21606",
        message: "The 'From' phone number provided is not a valid message-capable phone number for this destination."
      ),
      sent_at_missing: Error.new(
        code: "35111",
        message: "SendAt cannot be empty for ScheduleType 'fixed'"
      ),
      scheduled_message_messaging_service_sid_missing: Error.new(
        code: "35118",
        message: "MessagingServiceSid is required to schedule a message"
      ),
      send_at_invalid: Error.new(
        code: "35114",
        message: "SendAt time must be between 900 seconds and 7 days (604800 seconds) in the future"
      ),
      delete_before_complete: Error.new(
        code: "20009",
        message: "Cannot delete this resource before it is complete"
      ),
      call_blocked_by_blocked_list: Error.new(
        code: "13225", message: "Call blocked by block list"
      ),
      calling_number_unsupported_or_invalid: Error.new(
        code: "13224",
        message: "Calling this number is unsupported or the number is invalid"
      ),
      message_not_cancelable: Error.new(
        code: "30409",
        message: "Message is not in a cancelable state."
      ),
      verify_invalid_verification_status: Error.new(
        code: "S60200", message: "Invalid verification status"
      ),
      no_target_verification_specified: Error.new(
        code: "60221,", message: "Either a 'To' number or 'VerificationSid' must be specified"
      ),
      max_check_attempts_reached: Error.new(
        code: "60202", message: "Max check attempts reached"
      ),
      max_send_attempts_reached: Error.new(
        code: "60203", message: "Max send attempts reached"
      )
    }.freeze

    def self.fetch(error)
      ERRORS.fetch(error)
    end
  end
end
