require "rails_helper"

module TwiMLParser
  RSpec.describe Parser do
    it "handles parses TwiML" do
      twiml = <<~TWIML
        <?xml version="1.0" encoding="UTF-8" ?>
        <Response>
          <Message action="/status_callback.json">Hello world</Message>
          <Redirect method="GET">https://www.example.com/status_callback.json</Redirect>
        </Response>
      TWIML
      parser = Parser.new

      result = parser.parse(twiml)

      expect(result[0]).to have_attributes(
        body: "Hello world",
        action: "/status_callback.json"
      )
      expect(result[1]).to have_attributes(
        url: "https://www.example.com/status_callback.json",
        method: "GET"
      )
    end
  end
end
