class OutboundCallJob < ApplicationJob
  class RetryJob < StandardError; end

  def perform(phone_call, call_service_client: CallService::Client.new)
    return unless phone_call.status.in?(%w[queued initiating])

    phone_call.initiate!

    decorated_phone_call = PhoneCallDecorator.new(phone_call)
    response = call_service_client.create_call(
      sid: decorated_phone_call.sid,
      account_sid: decorated_phone_call.account_sid,
      account_auth_token: decorated_phone_call.account.auth_token,
      direction: decorated_phone_call.direction,
      api_version: TwilioAPISerializer::API_VERSION,
      voice_url: decorated_phone_call.voice_url,
      voice_method: decorated_phone_call.voice_method,
      twiml: decorated_phone_call.twiml,
      to: decorated_phone_call.to,
      from: decorated_phone_call.caller_id,
      routing_instructions: {
        dial_string: decorated_phone_call.dial_string,
        nat_supported: decorated_phone_call.sip_trunk.outbound_symmetric_latching_supported
      },
      routing_parameters: RoutingParameters.new(
        sip_trunk: phone_call.sip_trunk,
        destination: phone_call.to
      ).to_h
    )

    # re-enqueue job with exponential backoff
    raise RetryJob, "Response body: #{response.body}" unless response.success?

    phone_call.external_id = response.fetch(:id)
    phone_call.mark_as_initiated!
  end
end
