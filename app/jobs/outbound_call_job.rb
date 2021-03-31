class OutboundCallJob < ApplicationJob
  class RetryJob < StandardError; end

  def perform(phone_call, http_client: default_http_client)
    routing_instructions = OutboundCallRouter.new(phone_call.to).routing_instructions

    response = http_client.post(
      "/calls",
      {
        sid: phone_call.id,
        account_sid: phone_call.account.id,
        account_auth_token: phone_call.account.auth_token,
        direction: PhoneCallSerializer::TWILIO_CALL_DIRECTIONS.fetch("outbound"),
        api_version: ApplicationSerializer::API_VERSION,
        voice_url: phone_call.voice_url,
        voice_method: phone_call.voice_method,
        to: phone_call.to,
        from: phone_call.from,
        routing_instructions: routing_instructions
      }.to_json
    )

    # re-enqueue job with exponential backoff
    raise RetryJob, "Response body: #{response.body}" unless response.success?

    phone_call.external_id = JSON.parse(response.body).fetch("id")
    phone_call.initiate!
  rescue OutboundCallRouter::UnsupportedGatewayError
    phone_call.cancel!
  end

  private

  def default_http_client
    @default_http_client ||= Faraday.new(url: Rails.configuration.app_settings.fetch(:ahn_host)) do |conn|
      conn.headers["content-type"] = "application/json"
      conn.adapter Faraday.default_adapter
      conn.basic_auth(
        Rails.configuration.app_settings.fetch(:ahn_username),
        Rails.configuration.app_settings.fetch(:ahn_password)
      )
    end
  end
end
