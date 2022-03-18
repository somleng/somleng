require "rails_helper"

module Services
  RSpec.describe RecordingRequestSchema, type: :request_schema do
    it "validates phone_call_id" do
      expect(
        validate_request_schema(input_params: { phone_call_id: "phone-call-id" })
      ).to have_valid_field(:phone_call_id)

      expect(
        validate_request_schema(input_params: { phone_call_id: "" })
      ).not_to have_valid_field(:phone_call_id)

      expect(
        validate_request_schema(input_params: {})
      ).not_to have_valid_field(:phone_call_id)
    end

    it "validates status_callback_url" do
      expect(
        validate_request_schema(input_params: { status_callback_url: "http://example.com/callback" })
      ).to have_valid_field(:status_callback_url)

      expect(
        validate_request_schema(input_params: { status_callback_url: "invalid-url" })
      ).not_to have_valid_field(:status_callback_url)

      expect(
        validate_request_schema(input_params: {})
      ).to have_valid_field(:status_callback_url)
    end

    it "validates status_callback_method" do
      expect(
        validate_request_schema(input_params: { status_callback_method: "POST" })
      ).to have_valid_field(:status_callback_method)

      expect(
        validate_request_schema(input_params: { status_callback_method: "GET" })
      ).to have_valid_field(:status_callback_method)

      expect(
        validate_request_schema(input_params: { status_callback_method: "invalid-value" })
      ).not_to have_valid_field(:status_callback_method)

      expect(
        validate_request_schema(input_params: {})
      ).to have_valid_field(:status_callback_method)
    end

    it "normalizes output" do
      phone_call = create(:phone_call)

      schema = validate_request_schema(
        input_params: {
          phone_call_id: phone_call.id,
          status_callback_url: "https://example.com/callback"
        }
      )

      expect(schema.output).to eq(
        phone_call: phone_call,
        account: phone_call.account,
        status_callback_url: "https://example.com/callback",
        status_callback_method: "POST"
      )
    end

    def validate_request_schema(...)
      RecordingRequestSchema.new(...)
    end
  end
end
