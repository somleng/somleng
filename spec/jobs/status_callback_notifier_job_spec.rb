require "rails_helper"

RSpec.describe StatusCallbackNotifierJob do
  include_examples "aws_sqs_queue_url"

  describe "#perform(phone_call_id)" do
    it "notifies the status callback url via HTTP POST by default" do
      phone_call = create(
        :phone_call,
        :not_answered,
        :with_status_callback_url,
        call_data_record: build(:call_data_record, bill_sec: "15")
      )
      stub_request(:post, phone_call.status_callback_url)
      job = described_class.new

      job.perform(phone_call.id)

      expect(WebMock).to have_requested(:post, phone_call.status_callback_url)
      request_payload = WebMock.request_params(WebMock.requests.last)
      expect(request_payload.fetch("CallStatus")).to eq("no-answer")
      expect(request_payload.fetch("CallDuration")).to eq("15")
    end

    it "notifies the status callback url via HTTP GET if specified" do
      phone_call = create(
        :phone_call,
        :with_status_callback_url,
        status_callback_method: "GET"
      )
      stub_request(:get, phone_call.status_callback_url)
      job = described_class.new

      job.perform(phone_call.id)

      expect(WebMock).to have_requested(:get, phone_call.status_callback_url)
    end
  end
end
