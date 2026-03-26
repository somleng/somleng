require "rails_helper"

module TwilioAPI
  RSpec.describe NotifyWebhook do
    it "notifies a webhook via HTTP POST by default" do
      account = create(:account)
      url = "https://www.example.com/status_callback_url?b=2&a=1"
      request_validator = twilio_request_validator(account)
      stub_request(:post, url)

      NotifyWebhook.call(account:, url:, http_method: "POST", params: { foo: :bar })

      expect(WebMock).to have_requested(:post, url).with { |request|
        payload = Rack::Utils.parse_nested_query(request.body)

        expect(payload).to include("foo" => "bar")

        expect(
          request_validator.validate(
            url,
            payload,
            request.headers.fetch("X-Twilio-Signature")
          )
        ).to be(true)
      }
    end

    it "notifies a webhook with HTTP GET" do
      account = create(:account)
      request_validator = twilio_request_validator(account)
      expected_request_url = "https://www.example.com/status_callback_url?b=2&a=1&foo=bar"
      stub_request(:get, expected_request_url)

      NotifyWebhook.call(account:, url: "https://www.example.com/status_callback_url?b=2&a=1", http_method: "GET", params: { foo: :bar })

      expect(WebMock).to have_requested(:get, expected_request_url).with { |request|
        expect(
          request_validator.validate(
            expected_request_url,
            {},
            request.headers.fetch("X-Twilio-Signature")
          )
        ).to be(true)
      }
    end

    def twilio_request_validator(account)
      Twilio::Security::RequestValidator.new(account.auth_token)
    end
  end
end
