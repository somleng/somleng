require "rails_helper"

module TwilioAPI
  RSpec.describe NotifyWebhook do
    it "notifies a webhook via HTTP POST by default" do
      account = create(:account)
      url = "https://www.example.com/status_callback_url?b=2&a=1"
      http_method = "POST"
      params = { foo: :bar }
      stub_request(:post, url)

      NotifyWebhook.call(account:, url:, http_method:, params:)

      expect(WebMock).to have_requested(:post, url).with { |request|
        payload = Rack::Utils.parse_nested_query(request.body)

        expect(payload).to include("foo" => "bar")

        validator = Twilio::Security::RequestValidator.new(account.auth_token)
        expect(
          validator.validate(
            url,
            payload,
            request.headers["X-Twilio-Signature"]
          )
        ).to eq(true)
      }
    end
  end
end
