require "rails_helper"

module TwilioAPI
  RSpec.describe IncomingPhoneNumberRequestSchema, type: :request_schema do
    it "validates PhoneNumber" do
      account = create(:account)
      public_number = create(:phone_number, visibility: :public, carrier: account.carrier)
      private_number = create(:phone_number, visibility: :private, carrier: account.carrier)

      expect(
        validate_request_schema(
          input_params: {
            PhoneNumber: public_number.number.to_s
          },
          options: { account: }
        )
      ).to have_valid_field(:PhoneNumber)

      expect(
        validate_request_schema(
          input_params: {
            To: private_number.number.to_s
          }
        )
      ).not_to have_valid_field(:PhoneNumber)
    end

    it "validates FriendlyName" do
      expect(
        validate_request_schema(
          input_params: {
            FriendlyName: "My Awesome Number"
          }
        )
      ).to have_valid_field(:FriendlyName)

      expect(
        validate_request_schema(
          input_params: {
            FriendlyName: "A" * 65
          }
        )
      ).not_to have_valid_field(:FriendlyName)
    end

    it "validates VoiceUrl" do
      expect(
        validate_request_schema(
          input_params: {
            VoiceUrl: "https://www.your-voice-url.com/example"
          }
        )
      ).to have_valid_field(:VoiceUrl)

      expect(
        validate_request_schema(
          input_params: {
            VoiceUrl: "invalid"
          }
        )
      ).not_to have_valid_field(:VoiceUrl)
    end

    it "validates VoiceMethod" do
      expect(
        validate_request_schema(
          input_params: {
            VoiceMethod: "GET"
          }
        )
      ).to have_valid_field(:VoiceMethod)

      expect(
        validate_request_schema(
          input_params: {
            VoiceMethod: "HEAD"
          }
        )
      ).not_to have_valid_field(:VoiceMethod)
    end

    it "validates SmsUrl" do
      expect(
        validate_request_schema(
          input_params: {
            SmsUrl: "https://www.your-sms-url.com/example"
          }
        )
      ).to have_valid_field(:SmsUrl)

      expect(
        validate_request_schema(
          input_params: {
            SmsUrl: "invalid"
          }
        )
      ).not_to have_valid_field(:SmsUrl)
    end

    it "validates SmsMethod" do
      expect(
        validate_request_schema(
          input_params: {
            SmsMethod: "GET"
          }
        )
      ).to have_valid_field(:SmsMethod)

      expect(
        validate_request_schema(
          input_params: {
            SmsMethod: "HEAD"
          }
        )
      ).not_to have_valid_field(:SmsMethod)
    end

    it "validates StatusCallback" do
      expect(
        validate_request_schema(
          input_params: {
            StatusCallback: "https://www.your-status-callback-url.com/example"
          }
        )
      ).to have_valid_field(:StatusCallback)

      expect(
        validate_request_schema(
          input_params: {
            StatusCallback: "invalid"
          }
        )
      ).not_to have_valid_field(:StatusCallback)
    end

    it "validates StatusCallbackMethod" do
      expect(
        validate_request_schema(
          input_params: {
            StatusCallbackMethod: "GET"
          }
        )
      ).to have_valid_field(:StatusCallbackMethod)

      expect(
        validate_request_schema(
          input_params: {
            StatusCallbackMethod: "HEAD"
          }
        )
      ).not_to have_valid_field(:StatusCallbackMethod)
    end


    it "handles post processing" do
      account = create(:account)
      phone_number = create(:phone_number, number: "12513095500", visibility: :public, carrier: account.carrier)

      schema = validate_request_schema(
        input_params: {
          PhoneNumber: "+12513095500",
          FriendlyName: "My Awesome Phone Number",
          VoiceUrl: "https://example.com/voice",
          VoiceMethod: "GET",
          SmsUrl: "https://example.com/sms",
          SmsMethod: "GET",
          StatusCallback: "https://example.com/status-callback",
          StatusCallbackMethod: "GET"
        },
        options: { account: }
      )

      expect(schema.output).to eq(
        account:,
        phone_number:,
        friendly_name: "My Awesome Phone Number",
        voice_url: "https://example.com/voice",
        voice_method: "GET",
        sms_url: "https://example.com/sms",
        sms_method: "GET",
        status_callback_url: "https://example.com/status-callback",
        status_callback_method: "GET"
      )
    end

    def validate_request_schema(input_params:, options: {})
      options[:account] ||= build_stubbed(:account)

      IncomingPhoneNumberRequestSchema.new(input_params:, options:)
    end
  end
end
