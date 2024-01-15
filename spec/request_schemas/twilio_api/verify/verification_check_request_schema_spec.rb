require "rails_helper"

module TwilioAPI
  module Verify
    RSpec.describe VerificationCheckRequestSchema, type: :request_schema do
      it "validates either To or VerificationSid is specified" do
        verification = create(:verification, status: :pending)

        expect(
          validate_request_schema(
            input_params: {
              To: verification.to
            },
            options: {
              verification_service: verification.verification_service
            }
          )
        ).to have_valid_schema

        expect(
          validate_request_schema(
            input_params: {
              VerificationSid: verification.id
            },
            options: {
              verification_service: verification.verification_service
            }
          )
        ).to have_valid_schema

        expect(
          validate_request_schema(
            input_params: {}
          )
        ).not_to have_valid_schema(
          error_message: ApplicationError::Errors.fetch(:no_target_verification_specified).message
        )
      end

      it "validates the max check attempts has not been reached" do
        too_many_check_attempts_verification = create(
          :verification, :too_many_check_attempts, status: :pending
        )

        expect(
          validate_request_schema(
            input_params: {
              VerificationSid: too_many_check_attempts_verification.id
            },
            options: {
              verification_service: too_many_check_attempts_verification.verification_service
            }
          )
        ).not_to have_valid_schema(
          error_message: ApplicationError::Errors.fetch(:max_check_attempts_reached).message
        )
      end

      it "handles post processing" do
        verification = create(:verification, status: :pending)

        schema = validate_request_schema(
          input_params: {
            VerificationSid: verification.id,
            Code: "1234"
          },
          options: { verification_service: verification.verification_service }
        )

        expect(schema.output).to eq(
          verification:,
          code: "1234"
        )
      end

      def validate_request_schema(input_params:, options: {})
        options[:verification_service] ||= build_stubbed(:verification_service)
        options[:account] ||= options[:verification_service].account
        options[:verifications_scope] ||= options[:verification_service].verifications.pending

        VerificationCheckRequestSchema.new(input_params:, options:)
      end
    end
  end
end
