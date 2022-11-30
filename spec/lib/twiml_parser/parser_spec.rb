require "rails_helper"

module TwiMLParser
  RSpec.describe Parser do
    describe "#parse" do
      context "<Message>" do
        # https://www.twilio.com/docs/messaging/twiml/message

        it "handles text in the body" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Message>Hello world</Message>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          result = parser.parse.first

          expect(result.body).to eq("Hello world")
        end

        it "handles <Body> nouns" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Message>
                <Body>Hello world</Body>
              </Message>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          result = parser.parse.first

          expect(result.body).to eq("Hello world")
        end

        it "handles message attributes" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Message to="855715111111" from="855715222222" action="/twiml_action.xml" method="get">Hello world</Message>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          result = parser.parse.first

          expect(result).to have_attributes(
            body: "Hello world",
            to: "855715111111",
            from: "855715222222",
            action: "/twiml_action.xml",
            method: "GET"
          )
        end

        it "validates the method attribute" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Message method="HEAD">Hello world</Message>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          expect { parser.parse }.to raise_error(
            TwiMLError, /Invalid attribute/
          )
        end

        it "validates the Body" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Message>
                <Foo>Hello world</Foo>
              </Message>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          expect { parser.parse }.to raise_error(
            TwiMLError, /Invalid content/
          )
        end

        it "validates the action" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Message action="ftp://www.example.com">Hello world</Message>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          expect { parser.parse }.to raise_error(
            TwiMLError, /Invalid attribute/
          )
        end
      end

      context "<Redirect>" do
        # https://www.twilio.com/docs/messaging/twiml/redirect

        it "handles Redirect verbs" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Redirect>https://www.example.com</Redirect>
            </Response>
          TWIML

          parser = Parser.new(twiml)

          result = parser.parse.first

          expect(result.url).to eq("https://www.example.com")
        end

        it "handles the method attribute" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Redirect method="get">/example.xml</Redirect>
            </Response>
          TWIML

          parser = Parser.new(twiml)

          result = parser.parse.first

          expect(result).to have_attributes(
            url: "/example.xml",
            method: "GET"
          )
        end

        it "validates the url" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Redirect>ftp://www.example.com</Redirect>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          expect { parser.parse }.to raise_error(
            TwiMLError, /Invalid URL/
          )
        end

        it "validates the method" do
          twiml = <<~TWIML
            <?xml version="1.0" encoding="UTF-8" ?>
            <Response>
              <Redirect method="HEAD">https://www.example.com</Redirect>
            </Response>
          TWIML
          parser = Parser.new(twiml)

          expect { parser.parse }.to raise_error(
            TwiMLError, /Invalid attribute/
          )
        end
      end
    end
  end
end
