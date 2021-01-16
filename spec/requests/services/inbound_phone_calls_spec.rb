require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/inbound_phone_calls" do
    it "creates a phone call" do
      create(
        :incoming_phone_number,
        phone_number: "855716200876",
        voice_url: "https://example.com/voice.xml",
        voice_method: "POST",
        status_callback_url: "https://example.com/status_callback",
        status_callback_method: "POST"
      )

      post(
        services_inbound_phone_calls_path,
        params: {
          "to" => "855716200876",
          "from" => "85512234567",
          "external_id" => SecureRandom.uuid,
          "variables" => {
            "sip_from_host" => "103.9.189.2"
          }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/phone_call")
      expect(json_response).to include(
        "to" => "855716200876",
        "from" => "85512234567",
        "voice_url" => "https://example.com/voice.xml",
        "voice_method" => "POST",
        "status_callback_url" => "https://example.com/status_callback",
        "status_callback_method" => "POST"
      )
    end
  end
end
