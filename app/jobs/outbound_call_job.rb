class OutboundCallJob < ApplicationJob
  class RetryJob < StandardError; end

  def perform(phone_call, call_service_client: CallService::Client.new)
    return unless phone_call.status.in?(%w[queued initiating])
    return reschedule(phone_call) unless phone_call.sip_trunk.channels_available?

    phone_call.initiate! do
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
        routing_parameters: RoutingParameters.new(
          sip_trunk: phone_call.sip_trunk,
          destination: phone_call.to
        ).to_h
      )

      raise RetryJob, "Response body: #{response.body}" unless response.success?

      response.fetch(:id)
    end
  end

  private

  def reschedule(phone_call)
    ScheduledJob.perform_later(
      OutboundCallJob.to_s,
      phone_call,
      wait_until: 10.seconds.from_now
    )
  end
end
