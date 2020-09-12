class OutboundCallJob < ApplicationJob
  def perform(phone_call, http_client: default_http_client)
    routing_instructions = OutboundCallRouter.new(phone_call.to).routing_instructions
    return phone_call.cancel! if routing_instructions.blank?

    response = http_client.post(
      "/calls",
      {
        sid: phone_call.id,
        account_sid: phone_call.account.id,
        account_auth_token: phone_call.account.auth_token,
        direction: "outbound-api",
        api_version: ApplicationSerializer::API_VERSION,
        voice_url: phone_call.voice_url,
        voice_method: phone_call.voice_method,
        to: phone_call.to,
        from: phone_call.from,
        routing_instructions: routing_instructions
      }.to_json
    )

    if response.success?
      phone_call.external_id = JSON.parse(response.body).fetch("id")
      phone_call.initiate!
    else
      phone_call.cancel!
    end
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
