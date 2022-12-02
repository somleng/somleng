require "rails_helper"

RSpec.describe SendOutboundMessage do
  it "broadcast to sms gateway" do
    message = create(:message, :queued)

    expect {
      SendOutboundMessage.call(message)
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

    expect(message.status).to eq("sending")
  end

  it "handles messages that are not queued" do
    message = create(:message, :sent)

    SendOutboundMessage.call(message)

    expect(message.status).to eq("sent")
  end

  it "handles expired validity period" do
    message = create(:message, :queued, queued_at: 5.seconds.ago, validity_period: 5)

    SendOutboundMessage.call(message)

    expect(message.status).to eq("failed")
  end
end
