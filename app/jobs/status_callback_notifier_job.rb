class StatusCallbackNotifierJob < ApplicationJob
  HTTP_METHODS = {
    "GET" => :get,
    "POST" => :post
  }.freeze

  def perform(phone_call)
    status_callback_url = phone_call.status_callback_url
    http_method = HTTP_METHODS.fetch(phone_call.status_callback_method, :post)
    serializer = StatusCallbackSerializer.new(phone_call)
    payload = serializer.serializable_hash
    http_client.run_request(
      http_method,
      phone_call.status_callback_url,
      payload.to_query,
      "x-twilio-signature" => twilio_signature(
        payload: payload,
        url: status_callback_url,
        auth_token: phone_call.account.auth_token
      )
    )
  end

  private

  def twilio_signature(payload:, url:, auth_token:)
    data = url + payload.sort.join
    digest = OpenSSL::Digest.new("sha1")
    Base64.encode64(OpenSSL::HMAC.digest(digest, auth_token, data)).strip
  end

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
