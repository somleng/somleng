require "rails_helper"

RSpec.describe SMSMessageChannel, type: :channel do
  describe "#sent" do
    it "marks as sent when the message successfully sent" do
      sms_gateway = stub_current_sms_gateway
      message = create(:message, :initiated, sms_gateway:, status_callback_url: nil)

      subscribe
      perform :sent, id: message.id, status: "sent"

      expect(message.reload.status).to eq("sent")
      expect(ExecuteWorkflowJob).not_to have_been_enqueued.with("TwilioAPI::NotifyWebhook")
    end

    it "handles failed delivery" do
      sms_gateway = stub_current_sms_gateway
      message = create(:message, :initiated, sms_gateway:)

      subscribe
      perform :sent, id: message.id, status: "failed"

      expect(message.reload.status).to eq("failed")
    end

    it "sends a status callback" do
      sms_gateway = stub_current_sms_gateway
      message = create(
        :message,
        :initiated,
        sms_gateway:,
        status_callback_url: "https://www.example.com/message_status_callback",
        status_callback_method: "POST"
      )

      subscribe
      perform :sent, id: message.id, status: "sent"

      expect(message.reload.status).to eq("sent")
      expect(ExecuteWorkflowJob).to have_been_enqueued.with(
        "TwilioAPI::NotifyWebhook",
        account: message.account,
        url: "https://www.example.com/message_status_callback",
        http_method: "POST",
        params: hash_including(
          "MessageStatus" => "sent",
          "MessageSid" => message.id
        )
      )
    end

    describe "#received" do
      it "handles an inbound message" do
        sms_gateway = stub_current_sms_gateway

        subscribe
        perform :received, from: "85510777777", to: "85510888888", body: "message body"

        last_message = sms_gateway.carrier.messages.last
        expect(last_message).to have_attributes(
          from: "85510777777",
          to: "85510888888",
          body: "message body",
          direction: "inbound"
        )
      end
    end

    def stub_current_sms_gateway
      sms_gateway = create(:sms_gateway)
      stub_connection(current_sms_gateway: sms_gateway)
      sms_gateway
    end
  end
end
