require "rails_helper"

RSpec.describe InitiateOutboundMessage do
  it "broadcast to sms gateway" do
    message = create(:message, :queued)

    expect {
      InitiateOutboundMessage.call(message)
    }.to have_broadcasted_to(
      message.sms_gateway
    ).from_channel(
      SMSMessageChannel
    ).with(
      id: message.id,
      body: message.body,
      to: message.to,
      from: message.from,
      channel: message.channel
    )

    expect(message.status).to eq("initiated")
  end

  it "handles messages that are not queued" do
    message = create(:message, :sent)

    InitiateOutboundMessage.call(message)

    expect(message.status).to eq("sent")
  end

  it "handles expired validity period" do
    message = create(:message, :queued, validity_period: 5, created_at: 5.seconds.ago)

    InitiateOutboundMessage.call(message)

    expect(message.status).to eq("canceled")
  end
end
