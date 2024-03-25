require "rails_helper"

module Services
  RSpec.describe MediaStreamEventRequestSchema, type: :request_schema do
    it "validates media_stream_id" do
      media_stream = create(:media_stream)

      expect(
        validate_request_schema(input_params: { media_stream_id: media_stream.id })
      ).to have_valid_field(:media_stream_id)

      expect(
        validate_request_schema(input_params: { media_stream_id: "wrong" })
      ).not_to have_valid_field(:media_stream_id)
    end

    it "normalizes output" do
      media_stream = create(:media_stream)

      schema = validate_request_schema(
        input_params: {
          media_stream_id: media_stream.id,
          event: {
            type: "connect_failed"
          }
        }
      )

      expect(schema.output).to eq(
        media_stream:,
        phone_call: media_stream.phone_call,
        type: "connect_failed",
        details: {}
      )
    end

    def validate_request_schema(...)
      MediaStreamEventRequestSchema.new(...)
    end
  end
end
