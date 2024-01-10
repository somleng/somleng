require "rails_helper"

module TwilioAPI
  module Verify
    RSpec.describe VerificationServiceRequestSchema, type: :request_schema do
      it "validates FriendlyName" do
        expect(
          validate_request_schema(
            input_params: {
              FriendlyName: "a" * 32
            }
          )
        ).to have_valid_field(:FriendlyName)

        expect(
          validate_request_schema(
            input_params: {
              FriendlyName: "a" * 33
            }
          )
        ).not_to have_valid_field(:FriendlyName)

        expect(
          validate_request_schema(
            input_params: {
              FriendlyName: nil
            }
          )
        ).not_to have_valid_field(:FriendlyName)
      end

      it "validates CodeLength" do
        expect(
          validate_request_schema(
            input_params: {
              CodeLength: 4
            }
          )
        ).to have_valid_field(:CodeLength)

        expect(
          validate_request_schema(
            input_params: {}
          )
        ).to have_valid_field(:CodeLength)

        expect(
          validate_request_schema(
            input_params: {
              CodeLength: 1
            }
          )
        ).not_to have_valid_field(:CodeLength)

        expect(
          validate_request_schema(
            input_params: {
              CodeLength: 11
            }
          )
        ).not_to have_valid_field(:CodeLength)
      end

      it "handles post processing" do
        account = create(:account)

        schema = validate_request_schema(
          input_params: {
            FriendlyName: "My Verification Service"
          },
          options: { account: }
        )

        expect(schema.output).to eq(
          name: "My Verification Service",
          code_length: 4,
          account:,
          carrier: account.carrier
        )
      end

      def validate_request_schema(input_params:, options: {})
        options[:account] ||= build_stubbed(:account)

        VerificationServiceRequestSchema.new(input_params:, options:)
      end
    end
  end
end
