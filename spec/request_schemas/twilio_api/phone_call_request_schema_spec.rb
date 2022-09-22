require "rails_helper"

module TwilioAPI
  RSpec.describe PhoneCallRequestSchema, type: :request_schema do
    it "validates To" do
      account = create(:account, allowed_calling_codes: ["855"])
      account_with_no_sip_trunks = create(:account)
      create(:sip_trunk, carrier: account.carrier)
      expect(
        validate_request_schema(input_params: { To: "855716100235" }, options: { account: })
      ).to have_valid_field(:To)

      expect(
        validate_request_schema(input_params: { To: "8557199999999" },
                                options: { account: })
      ).not_to have_valid_field(:To, error_message: "is invalid")

      expect(
        validate_request_schema(input_params: { To: "61428234567" }, options: { account: })
      ).not_to have_valid_schema(error_message: "Call blocked by block list", error_code: "13225")

      expect(
        validate_request_schema(input_params: { To: "855716100235" },
                                options: { account: account_with_no_sip_trunks })
      ).not_to have_valid_schema(
        error_message: "Calling this number is unsupported or the number is invalid", error_code: "13224"
      )
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
        validate_request_schema(input_params: {})
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
      account = create(:account)
      sip_trunk = create(
        :sip_trunk,
        carrier: account.carrier,
        outbound_host: "sip.example.com"
      )
      schema = validate_request_schema(
        input_params: {
          To: "+855 68 308 531",
          From: "+855 716 100 234",
          Url: "https://www.example.com/voice_url.xml",
          Method: "GET",
          Twiml: "<Response><Say>Ahoy there!</Say></Response>",
          StatusCallback: "https://example.com/status-callback",
          StatusCallbackMethod: "GET"
        },
        options: {
          account:
        }
      )

      expect(schema.output).to eq(
        to: "85568308531",
        from: "855716100234",
        caller_id: "+855716100234",
        account:,
        carrier: account.carrier,
        sip_trunk:,
        dial_string: "85568308531@sip.example.com",
        voice_url: "https://www.example.com/voice_url.xml",
        voice_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "GET",
        twiml: nil,
        direction: :outbound
      )
    end

    it "handles normalization of From" do
      account = create(:account)
      create(:sip_trunk, carrier: account.carrier)

      schema = validate_request_schema(
        input_params: {
          To: "+855 68 308 531",
          From: "068 308 532"
        },
        options: {
          account:
        }
      )

      expect(schema.output).to include(
        to: "85568308531",
        from: "068308532",
        caller_id: "068308532"
      )
    end

    it "handles post processing when passing TwiML" do
      account = create(:account)
      create(
        :sip_trunk,
        carrier: account.carrier
      )
      schema = validate_request_schema(
        input_params: {
          To: "+855 716 100235",
          From: "1294",
          Twiml: "<Response><Say>Ahoy there!</Say></Response>"
        },
        options: {
          account:
        }
      )

      expect(schema.output).to include(
        voice_url: nil,
        voice_method: nil,
        twiml: "<Response><Say>Ahoy there!</Say></Response>"
      )
    end

    def validate_request_schema(input_params:, options: {})
      options[:account] ||= build_stubbed(:account)

      PhoneCallRequestSchema.new(input_params:, options:)
    end
  end
end
