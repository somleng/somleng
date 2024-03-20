require "rails_helper"

module Services
  RSpec.describe AudioStreamRequestSchema, type: :request_schema do
    it "validates phone_call_id" do
      phone_call = create(:phone_call)

      expect(
        validate_request_schema(input_params: { phone_call_id: phone_call.id })
      ).to have_valid_field(:phone_call_id)

      expect(
        validate_request_schema(input_params: { phone_call_id: "wrong" })
      ).not_to have_valid_field(:phone_call_id)
    end

    it "validates url" do
      expect(
        validate_request_schema(input_params: { url: "wss://example.com/audio" })
      ).to have_valid_field(:url)

      expect(
        validate_request_schema(input_params: { url: "" })
      ).not_to have_valid_field(:url)
    end

    it "normalizes output" do
      phone_call = create(:phone_call)

      schema = validate_request_schema(
        input_params: {
          phone_call_id: phone_call.id,
          url: "wss://example.com/audio"
        }
      )

      expect(schema.output).to eq(
        phone_call: phone_call,
        account: phone_call.account,
        url: "wss://example.com/audio"
      )
    end

    def validate_request_schema(...)
      AudioStreamRequestSchema.new(...)
    end
  end
end
