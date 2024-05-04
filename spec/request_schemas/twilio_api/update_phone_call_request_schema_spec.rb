require "rails_helper"

module TwilioAPI
  RSpec.describe UpdatePhoneCallRequestSchema, type: :request_schema do
    it "validates Status" do
      expect(
        validate_request_schema(input_params: { Status: "completed" })
      ).to have_valid_field(:Status)

      expect(
        validate_request_schema(input_params: { Status: "pending" })
      ).not_to have_valid_field(:Status)
    end

    it "validates Url" do
      expect(
        validate_request_schema(input_params: { Url: "https://www.example.com" })
      ).to have_valid_field(:Url)

      expect(
        validate_request_schema(input_params: { Url: "ftp://www.example.com" })
      ).not_to have_valid_field(:Url)
    end

    it "validates Twiml" do
      expect(
        validate_request_schema(input_params: { Twiml: "<Response><Say>Ahoy there!</Say></Response>" })
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

    it "handles post processing for status updates" do
      schema = validate_request_schema(
        input_params: {
          Status: "completed"
        }
      )

      expect(schema.output).to eq(
        status: "completed"
      )
    end

    it "handles post processing for URL updates" do
      schema = validate_request_schema(
        input_params: {
          Url: "https://www.example.com/voice_url.xml",
          Method: "GET",
          StatusCallback: "https://example.com/status-callback",
          StatusCallbackMethod: "GET"
        }
      )

      expect(schema.output).to eq(
        voice_url: "https://www.example.com/voice_url.xml",
        voice_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "GET"
      )
    end

    it "handles post processing for TwiML updates" do
      schema = validate_request_schema(
        input_params: {
          Twiml: "<Response><Say>Ahoy there!</Say></Response>"
        }
      )

      expect(schema.output).to eq(
        twiml: "<Response><Say>Ahoy there!</Say></Response>"
      )
    end

    def validate_request_schema(input_params:, options: {})
      options[:account] ||= build_stubbed(:account)
      options[:phone_call] ||= build_stubbed(:phone_call, account: options[:account])

      UpdatePhoneCallRequestSchema.new(input_params:, options:)
    end
  end
end
