require "rails_helper"

RSpec.describe StatusCallbackNotifierJob do
  it "notifies the status callback url via HTTP POST by default" do
    phone_call = create(
      :phone_call,
      :not_answered,
      status_callback_url: "https://www.example.com/status_callback_url",
      call_data_record: build(:call_data_record, bill_sec: "15")
    )
    stub_request(:post, "https://www.example.com/status_callback_url")

    StatusCallbackNotifierJob.new.perform(phone_call)

    expect(WebMock).to have_requested(:post, "https://www.example.com/status_callback_url").with(
      body: hash_including("CallStatus" => "no-answer", "CallDuration" => "15")
    )
  end
end
