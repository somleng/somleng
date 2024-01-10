require "rails_helper"

module TwilioAPI
  module Verify
    RSpec.describe UpdateVerificationRequestSchema, type: :request_schema do
      it "validates Status" do
        pending_verification = create(:verification, status: :pending)
        approved_verification = create(:verification, status: :approved)

        expect(
          validate_request_schema(
            input_params: {
              Status: "approved"
            },
            options: { verification: pending_verification }
          )
        ).to have_valid_field(:Status)

        expect(
          validate_request_schema(
            input_params: {
              Status: "canceled"
            },
            options: { verification: pending_verification }
          )
        ).to have_valid_field(:Status)

        expect(
          validate_request_schema(
            input_params: {
              Status: "pending"
            },
            options: { verification: pending_verification }
          )
        ).not_to have_valid_field(:Status)

        expect(
          validate_request_schema(
            input_params: {
              Status: "approved"
            },
            options: { verification: approved_verification }
          )
        ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:verify_invalid_verification_status).message)
      end

      it "handles post processing" do
        verification = create(:verification, status: "approved")

        schema = validate_request_schema(
          input_params: {
            Status: "approved"
          },
          options: { verification: }
        )

        expect(schema.output).to eq(
          event: :approve
        )
      end

      def validate_request_schema(input_params:, options: {})
        options[:verification] ||= build_stubbed(:verification)
        options[:account] ||= options[:verification].account

        UpdateVerificationRequestSchema.new(input_params:, options:)
      end
    end
  end
end
