require "rails_helper"

RSpec.describe SMSMessageChannel, type: :channel do
  describe "#sent" do
    it "handles sent delevery status" do
      sms_gateway = stub_current_sms_gateway
      message = create(
        :message,
        :sending,
        sms_gateway:,
        status_callback_url: "https://www.example.com/message_status_callback"
      )
      stub_request(:post, "https://www.example.com/message_status_callback")

      subscribe
      perform_enqueued_jobs do
        perform(:sent, id: message.id, status: "sent")
      end

      expect(message.reload).to have_attributes(
        status: "sent",
        sent_at: be_present
      )
      expect(WebMock).to(have_requested(:post, "https://www.example.com/message_status_callback").with { |request|
        request.body.include?("MessageStatus=sent")
      })
      expect(message.events.first).to have_attributes(
        type: "message.sent"
      )
    end

    it "handles delivered delevery status" do
      sms_gateway = stub_current_sms_gateway
      message = create(
        :message,
        :sending,
        sms_gateway:,
        status_callback_url: "https://www.example.com/message_status_callback"
      )
      stub_request(:post, "https://www.example.com/message_status_callback")

      subscribe
      perform_enqueued_jobs do
        perform(:sent, id: message.id, status: "delivered")
      end

      expect(message.reload).to have_attributes(
        status: "delivered",
        delivered_at: be_present
      )
      expect(WebMock).to(have_requested(:post, "https://www.example.com/message_status_callback").with { |request|
        request.body.include?("MessageStatus=delivered")
      })
      expect(message.events.first).to have_attributes(
        type: "message.delivered"
      )
    end

    it "handles failed delivery" do
      sms_gateway = stub_current_sms_gateway
      message = create(:message, :sending, sms_gateway:)

      subscribe
      perform(:sent, id: message.id, status: "failed")

      expect(message.reload).to have_attributes(
        status: "failed",
        failed_at: be_present
      )
    end
  end

  describe "#received" do
    it "handles an inbound message" do
      sms_gateway = stub_current_sms_gateway
      account = create(:account, carrier: sms_gateway.carrier)
      phone_number = create(
        :phone_number,
        :configured,
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST",
        carrier: sms_gateway.carrier,
        number: "85510888888",
        account:
      )
      stub_request(:post, "https://www.example.com/messaging.xml").to_return(body: <<~TWIML)
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response></Response>
      TWIML

      subscribe
      perform_enqueued_jobs do
        perform(:received, from: "85510777777", to: "85510888888", body: "message body")
      end

      last_message = sms_gateway.messages.last
      expect(last_message).to have_attributes(
        sms_gateway:,
        account:,
        phone_number:,
        from: "85510777777",
        to: "85510888888",
        body: "message body",
        direction: "inbound"
      )
      expect(WebMock).to(have_requested(:post, "https://www.example.com/messaging.xml"))
    end

    it "handles unconfigured phone numbers" do
      sms_gateway = stub_current_sms_gateway(name: "My SMS Gateway")

      subscribe
      perform(:received, from: "85510777777", to: "85510888888", body: "message body")

      expect(sms_gateway.messages).to be_empty
      expect(ErrorLog.last).to have_attributes(
        carrier: sms_gateway.carrier,
        error_message: "Phone number 85510888888 does not exist. SMS Gateway: My SMS Gateway"
      )
    end

    it "handles messages configured to be dropped" do
      sms_gateway = stub_current_sms_gateway
      account = create(:account, carrier: sms_gateway.carrier)
      messaging_service = create(
        :messaging_service, :drop, account:, carrier: sms_gateway.carrier
      )
      create(
        :phone_number,
        :configured,
        messaging_service:,
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST",
        carrier: sms_gateway.carrier,
        number: "85510888888",
        account:
      )

      subscribe
      perform(:received, from: "85510777777", to: "85510888888", body: "message body")

      expect(sms_gateway.messages).to be_empty
      expect(ErrorLog.count).to eq(0)
    end
  end

  def stub_current_sms_gateway(attributes = {})
    sms_gateway = create(:sms_gateway, attributes)
    stub_connection(current_sms_gateway: sms_gateway)
    sms_gateway
  end
end
