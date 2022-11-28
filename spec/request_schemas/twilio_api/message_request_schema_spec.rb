require "rails_helper"

module TwilioAPI
  RSpec.describe MessageRequestSchema, type: :request_schema do
    it "validates To" do
      account = create(:account)
      create(:sms_gateway, carrier: account.carrier)

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
            To: "855716100235"
          }
        )
      ).not_to have_valid_schema(error_message: "Landline or unreachable carrier")

      expect(
        validate_request_schema(
          input_params: {
            To: "019515116234"
          },
          options: { account: }
        )
      ).not_to have_valid_field(:To, error_message: "is invalid")
    end

    it "validates From" do
      account = create(:account)
      phone_number = create(:phone_number, account:)

      expect(
        validate_request_schema(
          input_params: {
            From: phone_number.number
          },
          options: { account: }
        )
      ).to have_valid_field(:From)

      expect(
        validate_request_schema(
          input_params: {
            From: "1234"
          }
        )
      ).not_to have_valid_schema(error_message: "The 'From' phone number provided is not a valid message-capable phone number for this destination.")
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
      phone_number = create(:phone_number, account:, number: "855716100234")
      sms_gateway = create(
        :sms_gateway,
        carrier: account.carrier
      )
      schema = validate_request_schema(
        input_params: {
          To: "+855 68 308 531",
          From: "+855 716 100 234",
          Body: "Hello World ✽",
          StatusCallback: "https://example.com/status-callback",
          StatusCallbackMethod: "GET",
          SmartEncoded: "true",
          ValidityPeriod: "5"
        },
        options: {
          account:
        }
      )

      expect(schema.output).to eq(
        to: "85568308531",
        from: "855716100234",
        body: "Hello World *",
        channel: nil,
        segments: 1,
        encoding: "GSM",
        account:,
        carrier: account.carrier,
        phone_number:,
        sms_gateway:,
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "GET",
        direction: :outbound_api,
        validity_period: 5
      )
    end

    def validate_request_schema(input_params:, options: {})
      options[:account] ||= build_stubbed(:account)

      MessageRequestSchema.new(input_params:, options:)
    end
  end
end
