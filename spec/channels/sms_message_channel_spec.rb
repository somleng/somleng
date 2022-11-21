require "rails_helper"

RSpec.describe SMSMessageChannel, type: :channel do
  describe "#sent" do
    it "marks as sent when the message successfully sent" do
      sms_gateway = stub_current_sms_gateway
      message = create(:message, :initiated, sms_gateway:)

      subscribe
      perform :sent, id: message.id, status: "sent"

      expect(message.reload.status).to eq("sent")
    end

    it "handles failed delivery" do
      sms_gateway = stub_current_sms_gateway
      message = create(:message, :initiated, sms_gateway:)

      subscribe
      perform :sent, id: message.id, status: "failed"

      expect(message.reload.status).to eq("failed")
    end

    def stub_current_sms_gateway
      sms_gateway = create(:sms_gateway)
      stub_connection(current_sms_gateway: sms_gateway)
      sms_gateway
    end
  end
end
