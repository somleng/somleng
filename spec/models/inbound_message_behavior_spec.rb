require "rails_helper"

RSpec.describe InboundMessageBehavior do
  describe "#configured?" do
    it "returns true for configured numbers" do
      incoming_phone_number = create(
        :incoming_phone_number,
        sms_url: "https://www.example.com/sms_url.xml",
        sms_method: "GET"
      )
      webhook_messaging_service = create(:messaging_service, :webhook)
      incoming_phone_number_with_messaging_service = create(
        :incoming_phone_number,
        messaging_service: webhook_messaging_service,
        account: webhook_messaging_service.account
      )
      drop_messaging_service = create(:messaging_service, :drop)
      incoming_phone_number_with_drop_messaging_service = create(
        :incoming_phone_number,
        sms_url: "https://www.example.com/sms_url.xml",
        sms_method: "GET",
        messaging_service: drop_messaging_service,
        account: drop_messaging_service.account
      )

      expect(InboundMessageBehavior.new(incoming_phone_number).configured?).to eq(true)
      expect(
        InboundMessageBehavior.new(incoming_phone_number_with_messaging_service).configured?
      ).to eq(true)
      expect(
        InboundMessageBehavior.new(incoming_phone_number_with_drop_messaging_service).configured?
      ).to eq(true)
    end
  end

  describe "#webhook_request" do
    it "returns the sms url and method by default" do
      incoming_phone_number = create(
        :incoming_phone_number,
        sms_url: "https://www.example.com/sms_url.xml",
        sms_method: "POST"
      )
      behavior = InboundMessageBehavior.new(incoming_phone_number)

      url, http_method = behavior.webhook_request

      expect(url).to eq("https://www.example.com/sms_url.xml")
      expect(http_method).to eq("POST")
    end

    it "returns the messaging service request url and method for webhooks" do
      messaging_service = create(
        :messaging_service,
        :webhook,
        inbound_request_url: "https://www.example.com/inbound_request.xml",
        inbound_request_method: "GET"
      )

      incoming_phone_number = create(
        :incoming_phone_number,
        sms_url: "https://www.example.com/sms_url.xml",
        sms_method: "POST",
        messaging_service:
      )
      behavior = InboundMessageBehavior.new(incoming_phone_number)

      url, http_method = behavior.webhook_request

      expect(url).to eq("https://www.example.com/inbound_request.xml")
      expect(http_method).to eq("GET")
    end

    it "returns the messaging url and method for defer to senders" do
      messaging_service = create(
        :messaging_service,
        :defer_to_sender,
        inbound_request_url: "https://www.example.com/inbound_request.xml",
        inbound_request_method: "GET"
      )

      incoming_phone_number = create(
        :incoming_phone_number,
        sms_url: "https://www.example.com/sms_url.xml",
        sms_method: "POST",
        messaging_service:
      )
      behavior = InboundMessageBehavior.new(incoming_phone_number)

      url, http_method = behavior.webhook_request

      expect(url).to eq("https://www.example.com/sms_url.xml")
      expect(http_method).to eq("POST")
    end
  end
end
