require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/recordings" do
    it "creates a recording" do
      phone_call = create(:phone_call)

      post(
        api_services_recordings_path,
        params: { phone_call_id: phone_call.id },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/recording")
    end
  end

  describe "PATCH /services/recordings/:id" do
    it "updates a recording" do
      recording = create(:recording, :in_progress)

      patch(
        api_services_recording_path(recording),
        params: {
          raw_recording_url: "https://raw-recordings.s3.amazonaws.com/recording.wav",
          external_id: "external-id"
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_api_response_schema("services/recording")
      expect(recording.reload).to have_attributes(
        raw_recording_url: "https://raw-recordings.s3.amazonaws.com/recording.wav",
        external_id: "external-id"
      )
      expect(ExecuteWorkflowJob).to have_been_enqueued.with("ProcessRecording", recording)
    end
  end
end
