class StatusCallbackNotifierJob < ApplicationJob
  def perform(phone_call)
    status_callback_url = phone_call.status_callback_url
    http_method = phone_call.status_callback_method == "GET" ? :get : :post
    serializer = StatusCallbackSerializer.new(phone_call)
    http_client.public_send(
      http_method,
      phone_call.status_callback_url,
      serializer.serializable_hash,
      "x-twilio-signature" => serializer.twilio_signature(
        url: status_callback_url,
        auth_token: phone_call.account.auth_token
      )
    )
  end

  private

  def http_client
    @http_client ||= Faraday.new do |conn|
      conn.headers["content-type"] = "application/x-www-form-urlencoded; charset=utf-8"
      conn.headers["user-agent"] = "TwilioProxy/1.1"
      conn.headers["accept"] = "*/*"
      conn.headers["cache-control"] = "max-age=#{72.hours.seconds}"
      conn.adapter Faraday.default_adapter
    end
  end
end
