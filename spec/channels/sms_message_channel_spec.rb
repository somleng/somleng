require "rails_helper"

RSpec.describe SMSMessageChannel, type: :channel do
  describe "#sent" do
    it "handles sent delivery status" do
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

    it "handles delivered delivery status" do
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
      incoming_phone_number = create(
        :incoming_phone_number,
        account:,
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST",
        number: "85510888888",
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
        incoming_phone_number:,
        phone_number: incoming_phone_number.phone_number,
        from: have_attributes(value: "85510777777"),
        to: have_attributes(value: "85510888888"),
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
        error_message: "Phone number 85510888888 does not exist."
      )
    end

    it "handles messages configured to be dropped" do
      sms_gateway = stub_current_sms_gateway
      account = create(:account, carrier: sms_gateway.carrier)
      messaging_service = create(
        :messaging_service, :drop, account:, carrier: sms_gateway.carrier
      )
      create(
        :incoming_phone_number,
        messaging_service:,
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST",
        number: "85510888888",
        account:
      )

      subscribe
      perform(:received, from: "85510777777", to: "85510888888", body: "message body")

      expect(sms_gateway.messages).to be_empty
      expect(ErrorLog.count).to eq(0)
    end
  end

  describe "#message_send_requested" do
    it "handles a message send request" do
      sms_gateway = stub_current_sms_gateway
      message = create(:message, :sending, sms_gateway:)
      stub_rating_engine_request(result: build_list(:rating_engine_cdr_response, 1, :success))

      subscribe
      perform(:message_send_requested, id: message.id)

      expect(message.send_request).to be_persisted
      expect(message.send_request).to have_attributes(
        sms_gateway:,
        message:
      )
      expect(transmissions.last).to match(
        "type" => "message_send_request_confirmed",
        "message" => {
          "id" => message.id,
          "body" => message.body,
          "to" => message.to.to_s,
          "from" => message.from.to_s,
          "channel" => message.channel
        }
      )
    end

    it "handles a messages that already have a send request" do
      sms_gateway = stub_current_sms_gateway
      message = create(:message, :sending, sms_gateway:)
      create(:message_send_request, message:, sms_gateway:)

      subscribe
      perform(:message_send_requested, id: message.id)

      expect(transmissions).to be_empty
    end

    it "handles insufficient balance errors" do
      sms_gateway = stub_current_sms_gateway
      account = create(:account, billing_enabled: true)
      create(:tariff_plan_subscription, account:, category: :outbound_messages)
      message = create(:message, :sending, sms_gateway:, account:)
      stub_rating_engine_request(
        result: build_list(:rating_engine_cdr_response, 1, :max_usage_exceeded)
      )

      subscribe
      perform(:message_send_requested, id: message.id)

      expect(message.reload).to have_attributes(
        status: "failed",
        error_code: ApplicationError::Errors.fetch(:insufficient_balance).code,
        send_request: be_present
      )
    end
  end

  def stub_current_sms_gateway(attributes = {})
    sms_gateway = create(:sms_gateway, attributes)
    stub_connection(current_sms_gateway: sms_gateway)
    sms_gateway
  end
end
