require "rails_helper"

RSpec.describe "Services" do
  describe "POST /inbound_phone_calls" do
    it "creates a phone call" do
      create(
        :incoming_phone_number,
        phone_number: "855716200876",
        voice_url: "https://example.com/voice.xml",
        voice_method: "POST"
      )

      post(
        services_inbound_phone_calls_path,
        params: {
          "To" => "855716200876",
          "From" => "85512234567",
          "ExternalSid" => SecureRandom.uuid,
          "Variables" => {
            "sip_from_host" => "103.9.189.2"
          }
        },
        headers: build_authorization_headers("services", "password")
      )

      # TODO: Use JSON schema
      expect(response.code).to eq("201")
      expect(json_response).to include(
        "to" => "+855716200876",
        "from" => "85512234567",
        "voice_url" => "https://example.com/voice.xml",
        "voice_method" => "POST"
      )
    end
  end
end
