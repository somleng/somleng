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

        VerificationRequestSchema.new(input_params:, options:)
      end
    end
  end
end
