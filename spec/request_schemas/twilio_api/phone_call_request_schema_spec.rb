require "rails_helper"

module TwilioAPI
  RSpec.describe PhoneCallRequestSchema, type: :request_schema do
    it "validates To" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      account_with_no_sip_trunks = create(:account)
      account_with_blocked_list = create(:account, allowed_calling_codes: [ "855" ])
      billing_enabled_account = create(:account, :billing_enabled, carrier:)
      create(:sip_trunk, carrier:)

      expect(
        validate_request_schema(
          input_params: {
            To: "855716100235"
          },
          options: { account: }
        )
      ).to have_valid_field(:To)

      expect(
        validate_request_schema(
          input_params: {
            To: "019515116234"
          },
          options: { account: }
        )
      ).not_to have_valid_field(:To, error_message: "is invalid")

      expect(
        validate_request_schema(
          input_params: {
            To: "8557199999999"
          },
          options: { account: }
        )
      ).not_to have_valid_field(:To, error_message: "is invalid")

      expect(
        validate_request_schema(
          input_params: {
            To: "61428234567",
            From: create(:incoming_phone_number, account: account_with_blocked_list).number.to_s,
            Url: "https://www.example.com/voice_url.xml"
          },
          options: { account: account_with_blocked_list }
        )
      ).not_to have_valid_schema(
        error_message: ApplicationError::Errors.fetch(:call_blocked_by_blocked_list).message
      )

      expect(
        validate_request_schema(
          input_params: {
            From: create(:incoming_phone_number, account: account_with_no_sip_trunks).number.to_s,
            To: "855716100235",
            Url: "https://www.example.com/voice_url.xml"
          },
          options: { account: account_with_no_sip_trunks }
        )
      ).not_to have_valid_schema(
        error_message: ApplicationError::Errors.fetch(:calling_number_unsupported_or_invalid).message
      )

      expect(
        validate_request_schema(
          input_params: {
            From: create(:incoming_phone_number, account: billing_enabled_account).number.to_s,
            To: "855716100235",
            Url: "https://www.example.com/voice_url.xml"
          },
          options: { account: billing_enabled_account }
        )
      ).not_to have_valid_schema(
        error_message: ApplicationError::Errors.fetch(:subscription_disabled).message
      )
    end

    it "validates From" do
      account = create(:account)
      incoming_phone_number = create(:incoming_phone_number, account:)

      expect(
        validate_request_schema(
          input_params: {
            From: incoming_phone_number.number.to_s
          },
          options: { account: }
        )
      ).to have_valid_field(:From)

      expect(
        validate_request_schema(
          input_params: {},
          options: { account: }
        )
      ).not_to have_valid_field(:From)

      expect(
        validate_request_schema(
          input_params: {
            From: "1234"
          }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:unverified_source_number).message)
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

      expect(
        validate_request_schema(input_params: { Url: "http://localhost:5200/api/v1/campaigns/callback" })
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
      carrier = create(:carrier)
      account = create(:account, carrier:)
      sip_trunk = create(
        :sip_trunk,
        carrier: account.carrier,
        outbound_host: "sip.example.com",
        region: "hydrogen"
      )
      incoming_phone_number = create(:incoming_phone_number, account:, number: "85568308530")
      schema = validate_request_schema(
        input_params: {
          To: "+855 68 308 531",
          From: "+855 68 308 530",
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

      expect(schema.success?).to be(true)
      expect(schema.output).to eq(
        to: "85568308531",
        from: "85568308530",
        caller_id: "+85568308530",
        incoming_phone_number:,
        phone_number: incoming_phone_number.phone_number,
        account:,
        carrier: account.carrier,
        sip_trunk:,
        region: "hydrogen",
        voice_url: "https://www.example.com/voice_url.xml",
        voice_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "GET",
        twiml: nil,
        direction: :outbound_api
      )
    end

    it "handles normalization of From" do
      account = create(:account)
      create(:incoming_phone_number, type: :short_code, number: "1234", account:)
      create(:sip_trunk, carrier: account.carrier)

      schema = validate_request_schema(
        input_params: {
          To: "+855 68 308 531",
          From: "12 34",
          Url: "https://www.example.com/voice_url.xml",
        },
        options: {
          account:
        }
      )

      expect(schema.success?).to be(true)
      expect(schema.output).to include(
        to: "85568308531",
        from: "1234",
        caller_id: "1234"
      )
    end

    it "handles post processing when passing TwiML" do
      account = create(:account)
      create(:incoming_phone_number, type: :short_code, number: "1234", account:)
      create(
        :sip_trunk,
        carrier: account.carrier
      )
      schema = validate_request_schema(
        input_params: {
          To: "+855 716 100235",
          From: "1234",
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
