require "rails_helper"

RSpec.describe NotifyPhoneCallStatusCallback do
  it "notifies the status callback url via HTTP POST by default" do
    phone_call = create(
      :phone_call,
      :not_answered,
      from: "2442",
      to: "85512334667",
      status_callback_url: "https://www.example.com/status_callback_url?b=2&a=1",
      call_data_record: build(:call_data_record, bill_sec: "15")
    )
    stub_request(:post, phone_call.status_callback_url)

    NotifyPhoneCallStatusCallback.call(phone_call)

    expect(WebMock).to have_requested(:post, phone_call.status_callback_url).with { |request|
      payload = Rack::Utils.parse_nested_query(request.body)

      expect(payload).to include(
        "CallStatus" => "no-answer",
        "CallDuration" => "15",
        "From" => "2442",
        "To" => "+85512334667"
      )

      validator = Twilio::Security::RequestValidator.new(phone_call.account.auth_token)
      expect(
        validator.validate(
          phone_call.status_callback_url,
          payload,
          request.headers["X-Twilio-Signature"]
        )
      ).to eq(true)
    }
  end
end
