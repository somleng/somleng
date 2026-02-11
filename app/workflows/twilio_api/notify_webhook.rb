module TwilioAPI
  class NotifyWebhook < ApplicationWorkflow
    HTTP_METHODS = {
      "GET" => :get,
      "POST" => :post
    }.freeze

    attr_reader :account, :url, :http_method, :params

    def initialize(account:, url:, http_method:, params:)
      super()
      @account = account
      @url = url
      @http_method = HTTP_METHODS.fetch(http_method, :post)
      @params = params
    end

    def call
      uri = HTTP::URI.parse(url)

      if http_method == :get
        uri.query_values = uri.query_values(Array).to_a.concat(params.to_a)
        http_client.get(
          uri,
          headers: {
            "X-Twilio-Signature" => twilio_signature(
              uri:,
              auth_token: account.auth_token
            )
          }
        )
      else
        http_client.post(
          uri,
          form: params,
          headers: {
            "X-Twilio-Signature" => twilio_signature(
              uri:,
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
end
