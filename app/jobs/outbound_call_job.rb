class OutboundCallJob < ApplicationJob
  class RetryJob < StandardError; end

  def perform(phone_call, call_service_client: CallService::Client.new)
    return unless phone_call.queued?

    phone_call = PhoneCallDecorator.new(phone_call)
    response = call_service_client.create_call(
      sid: phone_call.sid,
      account_sid: phone_call.account_sid,
      account_auth_token: phone_call.account.auth_token,
      direction: phone_call.direction,
      api_version: TwilioAPISerializer::API_VERSION,
      voice_url: phone_call.voice_url,
      voice_method: phone_call.voice_method,
      twiml: phone_call.twiml,
      to: phone_call.to,
      from: phone_call.caller_id,
      routing_instructions: {
        dial_string: phone_call.dial_string,
        nat_supported: phone_call.outbound_sip_trunk.nat_supported
      }
    )

    # re-enqueue job with exponential backoff
    raise RetryJob, "Response body: #{response.body}" unless response.success?

    phone_call.external_id = response.fetch(:id)
    phone_call.initiate!
  end
end
