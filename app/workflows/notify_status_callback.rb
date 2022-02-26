class NotifyStatusCallback < ApplicationJob
  HTTP_METHODS = {
    "GET" => :get,
    "POST" => :post
  }.freeze

  def perform(phone_call, callback_url, callback_http_method, call_params)
    status_callback_uri = HTTP::URI.parse(callback_url)
    http_method = HTTP_METHODS.fetch(callback_http_method, :post)

    if http_method == :get
      status_callback_uri.query_values = status_callback_uri.query_values(Array).to_a.concat(call_params.to_a)
      http_client.get(
        status_callback_uri,
        headers: {
          "X-Twilio-Signature" => twilio_signature(
            uri: status_callback_uri,
            auth_token: phone_call.account.auth_token
          )
        }
      )
    else
      http_client.post(
        status_callback_uri,
        form: call_params,
        headers: {
          "X-Twilio-Signature" => twilio_signature(
            uri: status_callback_uri,
            auth_token: phone_call.account.auth_token,
            payload: call_params
          )
        }
      )
    end
  end

  private

  def twilio_signature(uri:, auth_token:, payload: {})
    data = uri.to_s + payload.sort.join
    digest = OpenSSL::Digest.new("sha1")
    Base64.strict_encode64(OpenSSL::HMAC.digest(digest, auth_token, data))
  end

  def http_client
    @http_client ||= HTTP.follow.headers(
      "Content-Type" => "application/x-www-form-urlencoded; charset=utf-8",
      "User-Agent" => "TwilioProxy/1.1",
      "Accept" => "*/*",
      "Cache-Control" => "max-age=#{72.hours.seconds}"
    )
  end
end
