class StatusCallbackSerializer < ApplicationSerializer
  TWILIO_CALL_STATUS_MAPPINGS = {
    "queued" => "queued",
    "initiated" => "queued",
    "ringing" => "ringing",
    "answered" => "in-progress",
    "busy" => "busy",
    "failed" => "failed",
    "not_answered" => "no-answer",
    "completed" => "completed",
    "canceled" => "canceled"
  }.freeze

  TWILIO_CALL_DIRECTIONS = {
    "inbound" => "inbound",
    "outbound" => "outbound-api"
  }

  # https://www.twilio.com/docs/voice/api/call-resource#statuscallback

  # | Parameter     | Description                                                                                                                 |
  # | ------------- | --------------------------------------------------------------------------------------------------------------------------- |
  # | CallSid       | A unique identifier for this call, generated by Twilio.                                                                     |
  # | AccountSid    | Your Twilio account ID.                                                                                                     |
  # | From          | The phone number or client identifier of the party that initiated the call.                                                 |
  # | To            | The phone number or client identifier of the called party.                                                                  |
  # | CallStatus    | A descriptive status for the call.                                                                                          |
  # | ApiVersion    | The version of the Twilio API used to handle this call.                                                                     |
  # | Direction     | A string describing the direction of the call                                                                               |
  # | ForwardedFrom | This parameter is only set when Twilio receives a forwarded call.                                                           |
  # | CallerName    | This parameter is set when the IncomingPhoneNumber that received the call has set its VoiceCallerIdLookup value to true     |
  # | ParentCallSid | A unique identifier for the call that created this leg. If this is the first leg of a call, this parameter is not included. |

  def serializable_hash(_options = nil)
    super.merge(
      "CallSid" => object.id,
      "AccountSid" => object.account.id,
      "From" => object.from,
      "To" => object.to,
      "CallStatus" => TWILIO_CALL_STATUS_MAPPINGS.fetch(object.status),
      "ApiVersion" => ApplicationSerializer::API_VERSION,
      "Direction" => TWILIO_CALL_DIRECTIONS.fetch(phone_call.direction),
      "CallDuration" => object.duration,
      "SipResponseCode" => object.sip_response_code,
      "CallbackSource" => "call-progress-events",
      "Timestamp" => Time.current.utc.rfc2822,
      "SequenceNumber" => "0"
    )
  end

  def twilio_signature(url:, auth_token:)
    data = url + params.sort.join
    digest = OpenSSL::Digest.new("sha1")
    Base64.encode64(OpenSSL::HMAC.digest(digest, auth_token, data)).strip
  end
end
