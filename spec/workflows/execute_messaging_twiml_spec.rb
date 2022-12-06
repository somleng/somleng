require "rails_helper"

RSpec.describe ExecuteMessagingTwiML do
  it "handles empty responses" do
    message = create(
      :message,
      :inbound,
      sms_url: "https://www.example.com/messaging.xml",
      sms_method: "POST"
    )

    stub_request(:post, "https://www.example.com/messaging.xml").to_return(body: <<~TWIML)
      <?xml version="1.0" encoding="UTF-8" ?>
      <Response></Response>
    TWIML

    ExecuteMessagingTwiML.call(message:, url: message.sms_url, http_method: message.sms_method)

    expect(WebMock).to(have_requested(:post, "https://www.example.com/messaging.xml").with { |request|
      request.body.include?("MessageSid=#{message.id}")
    })
  end

  context "<Message> verb" do
    it "handles <Message> verbs" do
      sms_gateway = create(:sms_gateway, :connected)
      account = create(:account, carrier: sms_gateway.carrier)
      phone_number = create(
        :phone_number, :configured, account:, number: "85512888888", carrier: sms_gateway.carrier
      )

      message = create(
        :message,
        :inbound,
        account:,
        phone_number:,
        sms_gateway:,
        from: "85512345678",
        to: "85512888888",
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST"
      )

      stub_request(:post, "https://www.example.com/messaging.xml").to_return(body: <<~TWIML)
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response>
          <Message>Hello world</Message>
        </Response>
      TWIML

      ExecuteMessagingTwiML.call(message:, url: message.sms_url, http_method: message.sms_method)

      last_message = Message.last
      expect(last_message).to have_attributes(
        direction: "outbound_reply",
        carrier: message.carrier,
        account: message.account,
        from: "85512888888",
        to: "85512345678",
        body: "Hello world",
        status: "sending",
        phone_number:
      )
    end

    it "handles <Message> verbs with attributes" do
      carrier = create(:carrier)
      sms_gateway = create(:sms_gateway, :connected, carrier:)
      account = create(:account, carrier:)

      phone_number = create(
        :phone_number,
        :configured,
        carrier:,
        account:,
        number: "85512888888"
      )

      other_phone_number = create(
        :phone_number,
        :configured,
        carrier:,
        account:,
        number: "85512777777"
      )

      message = create(
        :message,
        :inbound,
        account:,
        phone_number:,
        from: "85512345678",
        to: "85512888888",
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST"
      )

      stub_request(:post, "https://www.example.com/messaging.xml").to_return(body: <<~TWIML)
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response>
          <Message to="85512999999" from="85512777777" action="/message_status_callback.xml" method="GET">
            <Body>Hello world</Body>
          </Message>
        </Response>
      TWIML

      ExecuteMessagingTwiML.call(message:, url: message.sms_url, http_method: message.sms_method)

      last_message = Message.last
      expect(last_message).to have_attributes(
        direction: "outbound_reply",
        carrier:,
        account:,
        phone_number: other_phone_number,
        from: "85512777777",
        to: "85512999999",
        body: "Hello world",
        status: "sending",
        status_callback_url: "https://www.example.com/message_status_callback.xml"
      )
    end
  end

  it "handles invalid responses" do
    message = create(
      :message,
      :inbound,
      sms_url: "https://www.example.com/messaging.xml",
      sms_method: "POST"
    )
    stub_request(:post, "https://www.example.com/messaging.xml").to_return(body: "")

    ExecuteMessagingTwiML.call(message:, url: message.sms_url, http_method: message.sms_method)

    expect(Message.count).to eq(1)
  end

  context "<Redirect> verb" do
    it "handles absolute URLs" do
      message = create(
        :message,
        :inbound,
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST"
      )

      stub_request(:post, "https://www.example.com/messaging.xml").to_return(body: <<~TWIML)
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response>
          <Redirect>https://www.example.com/redirect.xml</Redirect>
          <Message>This should never be reached!</Message>
        </Response>
      TWIML

      stub_request(:post, "https://www.example.com/redirect.xml").to_return(body: <<~TWIML)
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response></Response>
      TWIML

      ExecuteMessagingTwiML.call(message:, url: message.sms_url, http_method: message.sms_method)

      expect(WebMock).to(have_requested(:post, "https://www.example.com/redirect.xml"))
      expect(Message.count).to eq(1)
    end

    it "handles relative URLs" do
      message = create(
        :message,
        :inbound,
        sms_url: "https://www.example.com/messaging.xml",
        sms_method: "POST"
      )

      stub_request(:post, "https://www.example.com/messaging.xml").to_return(body: <<~TWIML)
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response>
          <Redirect method="GET">/redirect.xml</Redirect>
        </Response>
      TWIML

      stub_request(:get, %r{www.example.com/redirect.xml}).to_return(body: <<~TWIML)
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response></Response>
      TWIML

      ExecuteMessagingTwiML.call(message:, url: message.sms_url, http_method: message.sms_method)

      expect(WebMock).to(have_requested(:get, %r{\Ahttps://www.example.com/redirect.xml\?.+}))
    end
  end
end
