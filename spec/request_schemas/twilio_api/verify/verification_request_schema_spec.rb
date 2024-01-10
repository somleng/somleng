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

      it "validates duplicate verifications" do
        pending_verification = create(:verification, to: "855716100235", status: :pending)
        approved_verification = create(:verification, to: "855716100236", status: :approved)

        expect(
          validate_request_schema(
            input_params: {
              To: "+855716100235"
            },
            options: {
              verification_service: pending_verification.verification_service,
              verifications_scope: pending_verification.verification_service.verifications.pending
            }
          )
        ).not_to have_valid_schema(
          error_message: ApplicationError::Errors.fetch(:max_send_attempts_reached).message
        )

        expect(
          validate_request_schema(
            input_params: {
              To: "+855716100236"
            },
            options: {
              verification_service: approved_verification.verification_service,
              verifications_scope: approved_verification.verification_service.verifications.pending
            }
          )
        ).to have_valid_schema
      end

      it "handles post processing" do
        verification_service = create(:verification_service)

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
          to: "855715100987"
        )
      end

      def validate_request_schema(input_params:, options: {})
        options[:verification_service] ||= build_stubbed(:verification_service)
        options[:account] ||= options[:verification_service].account
        options[:verifications_scope] ||= options[:verification_service].verifications

        VerificationRequestSchema.new(input_params:, options:)
      end
    end
  end
end
