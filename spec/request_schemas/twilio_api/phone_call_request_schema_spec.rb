require "rails_helper"

module TwilioAPI
  RSpec.describe PhoneCallRequestSchema, type: :request_schema do
    it "validates To" do
      expect(
        validate_request_schema(input_params: { To: "855716100235" })
      ).to have_valid_field(:To)

      expect(
        validate_request_schema(input_params: { To: "8557199999999" })
      ).not_to have_valid_field(:To)
    end

    it "validates Url" do
      expect(
        validate_request_schema(input_params: { Url: "https://www.example.com" })
      ).to have_valid_field(:Url)

      expect(
        validate_request_schema(input_params: { Twiml: "<Response><Say>Ahoy there!</Say></Response>" })
      ).to have_valid_field(:Url)

      expect(
        validate_request_schema(input_params: { Url: "ftp://www.example.com" })
      ).not_to have_valid_field(:Url)

      expect(
        validate_request_schema(input_params: { })
      ).not_to have_valid_field(:Url)
    end

    it "validates Twiml" do
      expect(
        validate_request_schema(input_params: { Twiml: "<Response><Say>Ahoy there!</Say></Response>" })
      ).to have_valid_field(:Twiml)

      expect(
        validate_request_schema(input_params: { Url: "https://www.example.com" })
      ).to have_valid_field(:Twiml)

      expect(
        validate_request_schema(input_params: { Twiml: "invalid-payload" })
      ).not_to have_valid_field(:Twiml)
    end

    it "validates Method" do
      expect(
        validate_request_schema(input_params: { Method: "GET" })
      ).to have_valid_field(:Method)

      expect(
        validate_request_schema(input_params: { Method: "HEAD" })
      ).not_to have_valid_field(:Method)
    end

    it "validates StatusCallback" do
      expect(
        validate_request_schema(input_params: { StatusCallback: "https://www.example.com" })
      ).to have_valid_field(:StatusCallback)

      expect(
        validate_request_schema(input_params: { StatusCallback: "ftp://www.example.com" })
      ).not_to have_valid_field(:StatusCallback)
    end

    it "validates StatusCallbackMethod" do
      expect(
        validate_request_schema(input_params: { StatusCallbackMethod: "GET" })
      ).to have_valid_field(:StatusCallbackMethod)

      expect(
        validate_request_schema(input_params: { StatusCallbackMethod: "HEAD" })
      ).not_to have_valid_field(:StatusCallbackMethod)
    end

    it "handles post processing" do
      schema = validate_request_schema(
        input_params: {
          To: "+855 716 100235",
          From: "1294",
          Url: "https://www.example.com/voice_url.xml",
          Twiml: "<Response><Say>Ahoy there!</Say></Response>"
        }
      )

      expect(schema.output).to eq(
        to: "855716100235",
        from: "1294",
        voice_url: "https://www.example.com/voice_url.xml",
        voice_method: "POST",
        status_callback_url: nil,
        status_callback_method: nil,
        twiml: nil,
        direction: :outbound
      )
    end

    it "handles post processing when passing twiml" do
      schema = validate_request_schema(
        input_params: {
          To: "+855 716 100235",
          From: "1294",
          Twiml: "<Response><Say>Ahoy there!</Say></Response>"
        }
      )

      expect(schema.output).to include(
        voice_url: nil,
        voice_method: nil,
        twiml: "<Response><Say>Ahoy there!</Say></Response>"
      )
    end

    def validate_request_schema(options)
      PhoneCallRequestSchema.new(options)
    end
  end
end
