require "rails_helper"

module Services
  RSpec.describe UpdateRecordingRequestSchema, type: :request_schema do
    it "validates raw_recording_url" do
      expect(
        validate_request_schema(input_params: { raw_recording_url: "https://raw-recordings.s3.amazonaws.com/recording.wav" })
      ).to have_valid_field(:raw_recording_url)

      expect(
        validate_request_schema(input_params: { raw_recording_url: "invalid-url" })
      ).not_to have_valid_field(:raw_recording_url)

      expect(
        validate_request_schema(input_params: {})
      ).not_to have_valid_field(:raw_recording_url)
    end

    def validate_request_schema(...)
      UpdateRecordingRequestSchema.new(...)
    end
  end
end
