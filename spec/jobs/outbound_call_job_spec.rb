require "rails_helper"

describe OutboundCallJob do
  include_examples "aws_sqs_queue_url"

  it "calls the InitiateOutboundCall workflow" do
    phone_call = build_stubbed(:phone_call)
    allow(InitiateOutboundCall).to receive(:call)
    job = described_class.new

    job.perform(phone_call)

    expect(InitiateOutboundCall).to have_received(:call).with(phone_call: phone_call)
  end
end
