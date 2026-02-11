require "rails_helper"

module TwilioAPI
  RSpec.describe MessageRequestSchema, type: :request_schema do
    it "validates To" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      billing_enabled_account = create(:account, :billing_enabled, carrier:)
      unreachable_carrier_account = create(:account)
      create(:sms_gateway, carrier:)

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
            To: "855716100235",
            From: create(:incoming_phone_number, account: billing_enabled_account).number.to_s,
            Body: "Hello World"
          },
          options: { account: billing_enabled_account }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:subscription_disabled).message)

      expect(
        validate_request_schema(
          input_params: {
            To: "855716100235",
            From: create(:incoming_phone_number, account: unreachable_carrier_account).number.to_s,
            Body: "Hello World"
          },
          options: { account: unreachable_carrier_account }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:unreachable_carrier).message)

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
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:message_incapable_phone_number).message)
    end

    it "validates MessagingServiceSid" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      messaging_service = create(:messaging_service, account:, carrier:)
      incoming_phone_number = create(:incoming_phone_number, messaging_service:, account:)
      unconfigured_messaging_service = create(:messaging_service, account:, carrier:)

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
            From: incoming_phone_number.number.to_s
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
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:message_incapable_phone_number).message)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: "invalid"
          },
          options: { account: }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:messaging_service_blank).message)

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: unconfigured_messaging_service.id
          },
          options: { account: }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:messaging_service_no_senders).message)
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
      ).to have_valid_field(:SendAt)

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
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:sent_at_missing).message)

      expect(
        validate_request_schema(
          input_params: {
            ScheduleType: "fixed",
            SendAt: 20.minutes.from_now.iso8601
          }
        )
      ).not_to have_valid_schema(
        error_message: ApplicationError::Errors.fetch(:scheduled_message_messaging_service_sid_missing).message
      )

      expect(
        validate_request_schema(
          input_params: {
            MessagingServiceSid: "messaging-service-sid",
            ScheduleType: "fixed",
            SendAt: 1.minute.from_now.iso8601
          }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:send_at_invalid).message)

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
      carrier = create(:carrier)
      account = create(:account, carrier:)
      incoming_phone_number = create(:incoming_phone_number, account:, number: "855716100234")
      sms_gateway = create(:sms_gateway, carrier:)

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

      expect(schema.output).to include(
        to: "85568308531",
        from: have_attributes(value: "855716100234"),
        body: "Hello World *",
        channel: nil,
        segments: 1,
        encoding: "GSM",
        account:,
        messaging_service: nil,
        carrier: account.carrier,
        incoming_phone_number:,
        phone_number: incoming_phone_number.phone_number,
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
      create(:incoming_phone_number, messaging_service:, account:)
      create(:sms_gateway, carrier: account.carrier)
      send_at = Time.parse(5.days.from_now.iso8601)

      schema = validate_request_schema(
        input_params: {
          To: "85568308531",
          MessagingServiceSid: messaging_service.id,
          SendAt: send_at.iso8601,
          ScheduleType: "fixed",
          Body: "Hello World ✽"
        },
        options: { account: }
      )

      expect(schema.success?).to be(true)
      expect(schema.output).to include(
        from: nil,
        incoming_phone_number: nil,
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
