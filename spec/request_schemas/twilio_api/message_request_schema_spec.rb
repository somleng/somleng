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
      ).not_to have_valid_schema(error_message: Errors::UnreachableCarrierError.new.message)

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
      ).not_to have_valid_schema(error_message: Errors::MessageIncapablePhoneNumberError.new.message)
    end

    it "validates MessagingServiceSid" do
      account = create(:account)
      messaging_service = create(:messaging_service, account:, carrier: account.carrier)
      phone_number = create(:phone_number, :configured, messaging_service:, account:, carrier: account.carrier)
      unconfigured_messaging_service = create(:messaging_service, account:, carrier: account.carrier)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: messaging_service.id
          },
          options: { account: }
        )
      ).to have_valid_field(:MessagingServiceSid)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: messaging_service.id,
            From: phone_number.number
          },
          options: { account: }
        )
      ).to have_valid_field(:MessagingServiceSid)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: messaging_service.id,
            From: "85512333333"
          },
          options: { account: }
        )
      ).not_to have_valid_schema(error_message: Errors::MessageIncapablePhoneNumberError.new.message)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: "invalid"
          },
          options: { account: }
        )
      ).not_to have_valid_schema(error_message: Errors::MessagingServiceBlankError.new.message)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: unconfigured_messaging_service.id
          },
          options: { account: }
        )
      ).not_to have_valid_schema(error_message: Errors::MessagingServiceNoSendersError.new.message)
    end

    it "validates Body" do
      expect(
        validate_request_schema(
          input_params: {
            Body: "a" * 1600
          }
        )
      ).to have_valid_field(:Body)

      expect(
        validate_request_schema(
          input_params: {
            Body: "a" * 1601
          }
        )
      ).not_to have_valid_field(:Body)
    end

    it "validates StatusCallback" do
      expect(
        validate_request_schema(input_params: { StatusCallback: "https://www.example.com" })
      ).to have_valid_field(:StatusCallback)

      expect(
        validate_request_schema(input_params: { StatusCallback: "ftp://www.example.com" })
      ).not_to have_valid_field(:StatusCallback)
    end

    it "validates ScheduleType" do
      expect(
        validate_request_schema(input_params: { ScheduleType: "fixed" })
      ).to have_valid_field(:ScheduleType)

      expect(
        validate_request_schema(input_params: { ScheduleType: "wrong" })
      ).not_to have_valid_field(:ScheduleType)
    end

    it "validates SendAt" do
      expect(
        validate_request_schema(
          input_params: {
            SendAt: 5.days.from_now.iso8601
          }
        )
      ).not_to have_valid_field(:ScheduleType)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: "messaging-service-sid",
            ScheduleType: "fixed",
            SendAt: 5.days.from_now.iso8601
          }
        )
      ).to have_valid_schema

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: "messaging-service-sid",
            ScheduleType: "fixed",
            SendAt: "invalid"
          }
        )
      ).not_to have_valid_field(:SendAt)

      expect(
        validate_request_schema(
          input_params: {
            ScheduleType: "fixed",
            MessagingServiceSid: "messaging-service-sid"
          }
        )
      ).not_to have_valid_schema(error_message: Errors::SentAtMissingError.new.message)

      expect(
        validate_request_schema(
          input_params: {
            ScheduleType: "fixed",
            SendAt: 20.minutes.from_now.iso8601
          }
        )
      ).not_to have_valid_schema(
        error_message: Errors::ScheduledMessageMessagingServiceSidMissingError.new.message
      )

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: "messaging-service-sid",
            ScheduleType: "fixed",
            SendAt: 1.minute.from_now.iso8601
          }
        )
      ).not_to have_valid_schema(error_message: Errors::SendAtInvalidError.new.message)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: "messaging-service-sid",
            ScheduleType: "fixed",
            SendAt: 8.days.from_now.iso8601
          }
        )
      ).not_to have_valid_schema(error_message: "SendAt time must be between 900 seconds and 7 days (604800 seconds) in the future")
    end

    it "handles post processing" do
      account = create(:account)
      phone_number = create(:phone_number, account:, number: "855716100234")
      sms_gateway = create(:sms_gateway, carrier: account.carrier)

      schema = validate_request_schema(
        input_params: {
          To: "+855 68 308 531",
          From: "+855 716 100 234",
          Body: "Hello World ✽",
          StatusCallback: "https://example.com/status-callback",
          SmartEncoded: "true",
          ValidityPeriod: "5"
        },
        options: { account: }
      )

      expect(schema.output).to eq(
        to: "85568308531",
        from: "855716100234",
        body: "Hello World *",
        channel: nil,
        segments: 1,
        encoding: "GSM",
        account:,
        messaging_service: nil,
        carrier: account.carrier,
        phone_number:,
        sms_gateway:,
        status_callback_url: "https://example.com/status-callback",
        validity_period: 5,
        smart_encoded: true,
        send_at: nil,
        status: :queued
      )
    end

    it "handles messaging service post processing" do
      account = create(:account)
      messaging_service = create(
        :messaging_service,
        account:,
        carrier: account.carrier,
        smart_encoding: true,
        status_callback_url: "https://example.com/status-callback"
      )
      create(:phone_number, :configured, messaging_service:, account:)
      create(:sms_gateway, carrier: account.carrier)
      send_at = Time.parse(5.days.from_now.iso8601)

      schema = validate_request_schema(
        input_params: {
          To: "85568308531",
          MessagingServiceSid: messaging_service.id,
          SendAt: send_at.iso8601,
          Body: "Hello World ✽"
        },
        options: { account: }
      )

      expect(schema.output).to include(
        from: nil,
        phone_number: nil,
        body: "Hello World *",
        encoding: "GSM",
        status_callback_url: "https://example.com/status-callback",
        smart_encoded: true,
        messaging_service:,
        send_at:,
        status: :scheduled
      )
    end

    def validate_request_schema(input_params:, options: {})
      options[:account] ||= build_stubbed(:account)

      MessageRequestSchema.new(input_params:, options:)
    end
  end
end
