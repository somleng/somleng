require "rails_helper"

module TwilioAPI
  module Verify
    RSpec.describe VerificationRequestSchema, type: :request_schema do
      it "validates To" do
        expect(
          validate_request_schema(
            input_params: {
              To: "+855716100235"
            }
          )
        ).to have_valid_field(:To)

        expect(
          validate_request_schema(
            input_params: {
              To: "019515116234"
            }
          )
        ).not_to have_valid_field(:To, error_message: "is invalid")
      end

      it "validates Channel" do
        expect(
          validate_request_schema(
            input_params: {
              Channel: "sms"
            }
          )
        ).to have_valid_field(:Channel)

        expect(
          validate_request_schema(
            input_params: {
              Channel: "call"
            }
          )
        ).to have_valid_field(:Channel)

        expect(
          validate_request_schema(
            input_params: {
              Channel: "email"
            }
          )
        ).not_to have_valid_field(:Channel)
      end

      it "validates Locale" do
        expect(
          validate_request_schema(
            input_params: {
              Locale: "de"
            }
          )
        ).to have_valid_field(:Locale)

        expect(
          validate_request_schema(
            input_params: {
              Locale: "foo"
            }
          )
        ).not_to have_valid_field(:Locale)
      end

      it "validates max delivery attempts" do
        verification_service, = create_verification_service
        pending_verification = create(
          :verification,
          to: "855716100235",
          status: :pending,
          verification_service:
        )
        pending_verification_with_too_many_delivery_attempts = create(
          :verification,
          :too_many_delivery_attempts,
          to: "855716100236",
          status: :pending,
          verification_service:
        )

        expect(
          validate_request_schema(
            input_params: {
              To: pending_verification_with_too_many_delivery_attempts.to.to_s,
              Channel: "sms"
            },
            options: {
              verification_service:
            }
          )
        ).not_to have_valid_schema(
          error_message: ApplicationError::Errors.fetch(:max_send_attempts_reached).message
        )

        expect(
          validate_request_schema(
            input_params: {
              To: pending_verification.to.to_s,
              Channel: "sms"
            },
            options: {
              verification_service:
            }
          )
        ).to have_valid_schema
      end

      it "validates the message destination rules" do
        verification_service = create(:verification_service)
        verification_service_from_carrier_with_sms_gateway, = create_verification_service

        expect(
          validate_request_schema(
            input_params: {
              To: "855715100987",
              Channel: "sms"
            },
            options: {
              verification_service: verification_service_from_carrier_with_sms_gateway
            }
          )
        ).to have_valid_schema

        expect(
          validate_request_schema(
            input_params: {
              To: "855715100987",
              Channel: "sms"
            },
            options: {
              verification_service:
            }
          )
        ).not_to have_valid_schema(
          error_message: ApplicationError::Errors.fetch(:unreachable_carrier).message
        )
      end

      it "validates the phone call destination rules" do
        verification_service = create(:verification_service)
        verification_service_from_carrier_with_sip_trunk, = create_verification_service

        expect(
          validate_request_schema(
            input_params: {
              To: "855715100987",
              Channel: "call"
            },
            options: {
              verification_service: verification_service_from_carrier_with_sip_trunk
            }
          )
        ).to have_valid_schema

        expect(
          validate_request_schema(
            input_params: {
              To: "855715100987",
              Channel: "call"
            },
            options: {
              verification_service:
            }
          )
        ).not_to have_valid_schema(
          error_message: ApplicationError::Errors.fetch(:calling_number_unsupported_or_invalid).message
        )
      end

      it "validates a phone number is enabled" do
        verification_service = create(:verification_service)
        create(:phone_number, :disabled, carrier: verification_service.carrier)
        verification_service_from_carrier_with_configured_phone_number, = create_verification_service

        expect(
          validate_request_schema(
            input_params: {
              To: "855715100987",
              Channel: "sms"
            },
            options: {
              verification_service: verification_service_from_carrier_with_configured_phone_number
            }
          )
        ).to have_valid_schema

        expect(
          validate_request_schema(
            input_params: {
              To: "855715100987",
              Channel: "sms"
            },
            options: {
              verification_service:
            }
          )
        ).not_to have_valid_schema(
          error_message: ApplicationError::Errors.fetch(:verify_could_not_find_valid_phone_number).message
        )
      end

      it "handles post processing" do
        verification_service, phone_number = create_verification_service

        schema = validate_request_schema(
          input_params: {
            To: "+855 71 5100 987",
            Channel: "sms"
          },
          options: { verification_service: }
        )

        expect(schema.output).to eq(
          verification_service:,
          account: verification_service.account,
          carrier: verification_service.carrier,
          channel: "sms",
          to: "855715100987",
          delivery_attempt: {
            phone_number:,
            from: phone_number.number
          }
        )
      end

      it "finds an existing pending verification" do
        verification_service, = create_verification_service
        pending_verification = create(:verification, status: :pending, verification_service:)

        schema = validate_request_schema(
          input_params: {
            To: pending_verification.to.to_s,
            Channel: "call"
          },
          options: {
            verification_service:
          }
        )

        expect(schema.output).to include(
          verification: pending_verification
        )
      end

      it "respects the locale parameter" do
        verification_service, = create_verification_service

        schema = validate_request_schema(
          input_params: {
            To: "+855 71 5100 987",
            Channel: "sms",
            Locale: "de"
          },
          options: { verification_service: }
        )

        expect(schema.output).to include(locale: "de")
      end

      def validate_request_schema(input_params:, options: {})
        options[:verification_service] ||= build_stubbed(:verification_service)
        options[:account] ||= options[:verification_service].account
        options[:verifications_scope] ||= options[:verification_service].verifications.pending

        VerificationRequestSchema.new(input_params:, options:)
      end

      def create_verification_service(attributes = {})
        verification_service = create(:verification_service, attributes)
        phone_number = create(:phone_number, carrier: verification_service.carrier)
        create(:sms_gateway, carrier: verification_service.carrier, default_sender: phone_number)
        create(:sip_trunk, carrier: verification_service.carrier, default_sender: phone_number)
        [ verification_service, phone_number ]
      end
    end
  end
end
