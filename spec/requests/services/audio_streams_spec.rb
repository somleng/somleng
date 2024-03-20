require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/audio_streams" do
    it "creates an audio stream" do
      phone_call = create(:phone_call)

      post(
        api_services_audio_streams_path,
        params: {
          phone_call_id: phone_call.id,
          url: "wss://example.com/audio",
          custom_parameters: { "foo" => "bar" }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/audio_stream")
    end

    it "handles invalid requests" do
      post(
        api_services_audio_streams_path,
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema("services/api_errors")
    end
  end
end
