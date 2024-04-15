require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/media_streams" do
    it "creates a media stream" do
      phone_call = create(:phone_call)

      post(
        api_services_media_streams_path,
        params: {
          phone_call_id: phone_call.id,
          tracks: "inbound",
          url: "wss://example.com/audio",
          custom_parameters: { "foo" => "bar" }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/media_stream")
    end

    it "handles invalid requests" do
      post(
        api_services_media_streams_path,
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema("services/api_errors")
    end
  end
end
