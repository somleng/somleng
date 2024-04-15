require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/media_stream_events" do
    it "creates an media stream event" do
      media_stream = create(:media_stream)

      post(
        api_services_media_stream_events_path,
        params: {
          media_stream_id: media_stream.id,
          event: { type: "connect_failed", details: { foo: "bar" } }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(media_stream.reload).to have_attributes(
        status: "connect_failed",
        events: match_array(
          have_attributes(
            type: "connect_failed",
            details: { "foo" => "bar" }
          )
        )
      )
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
