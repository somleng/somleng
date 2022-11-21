class NotifyStatusCallback < ApplicationWorkflow
  HTTP_METHODS = {
    "GET" => :get,
    "POST" => :post
  }.freeze

  attr_reader :account, :callback_url, :callback_http_method, :params

  def initialize(account:, callback_url:, callback_http_method:, params:)
    @phone_call = phone_call
    @callback_url = callback_url
    @callback_http_method = callback_http_method
    @params = params
  end

  def call
    status_callback_uri = HTTP::URI.parse(callback_url)
    http_method = HTTP_METHODS.fetch(callback_http_method, :post)

    if http_method == :get
      status_callback_uri.query_values = status_callback_uri.query_values(Array).to_a.concat(params.to_a)
      http_client.get(
        status_callback_uri,
        headers: {
          "X-Twilio-Signature" => twilio_signature(
            uri: status_callback_uri,
            auth_token: account.auth_token
          )
        }
      )
    else
      http_client.post(
        status_callback_uri,
        form: params,
        headers: {
          "X-Twilio-Signature" => twilio_signature(
            uri: status_callback_uri,
            auth_token: account.auth_token,
            payload: params
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
