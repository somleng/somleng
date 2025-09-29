require "rails_helper"

RSpec.describe FailSendingMessages do
  it "fails sending messages" do
    messages = [
      create(:message, :sending),
      create(:message, :sending, sending_at: 5.minutes.ago),
      create(:message, :sent, sending_at: 5.minutes.ago)
    ]

    FailSendingMessages.call

    expect(messages[0].reload.status).to eq("sending")
    expect(messages[1].reload.status).to eq("failed")
    expect(messages[2].reload.status).to eq("sent")
  end
end
