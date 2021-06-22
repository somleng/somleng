class OutboundCallJob < ApplicationJob
  class RetryJob < StandardError; end

  def perform(phone_call, call_service_client: CallService::Client.new)
    routing_instructions = OutboundCallRouter.new(
      account: phone_call.account,
      destination: phone_call.to
    ).routing_instructions

    response = call_service_client.create_call(
      sid: phone_call.id,
      account_sid: phone_call.account.id,
      account_auth_token: phone_call.account.auth_token,
      direction: PhoneCallDecorator::TWILIO_CALL_DIRECTIONS.fetch("outbound"),
      api_version: ApplicationSerializer::API_VERSION,
      voice_url: phone_call.voice_url,
      voice_method: phone_call.voice_method,
      to: phone_call.to,
      from: phone_call.from,
      routing_instructions: routing_instructions
    )

    # re-enqueue job with exponential backoff
    raise RetryJob, "Response body: #{response.body}" unless response.success?

    phone_call.external_id = response.fetch(:id)
    phone_call.initiate!
  rescue OutboundCallRouter::UnsupportedGatewayError
    phone_call.cancel!
  end
end
