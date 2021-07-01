require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/inbound_phone_calls" do
    it "creates a phone call" do
      carrier = create(:carrier)
      create(
        :phone_number,
        :assigned_to_account,
        carrier: carrier,
        number: "855716200876",
        voice_url: "https://example.com/voice.xml",
        voice_method: "POST",
        status_callback_url: "https://example.com/status_callback",
        status_callback_method: "POST"
      )
      create(:inbound_sip_trunk, carrier: carrier, source_ip: "175.100.7.240")

      post(
        services_inbound_phone_calls_path,
        params: {
          "source_ip" => "175.100.7.240",
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
      expect(json_response(response.body)).to include(
        "to" => "855716200876",
        "from" => "85512234567",
        "voice_url" => "https://example.com/voice.xml",
        "voice_method" => "POST",
        "status_callback_url" => "https://example.com/status_callback",
        "status_callback_method" => "POST"
      )
    end

    it "handles invalid requests" do
      post(
        services_inbound_phone_calls_path,
        params: {},
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema("api_errors")
    end

    it "handles phone numbers which aren't assigned to an account" do
      carrier = create(:carrier)
      create(
        :phone_number,
        carrier: carrier,
        number: "855716200876"
      )
      create(:inbound_sip_trunk, carrier: carrier, source_ip: "175.100.7.240")

      post(
        services_inbound_phone_calls_path,
        params: {
          "source_ip" => "175.100.7.240",
          "to" => "855716200876",
          "from" => "85512234567",
          "external_id" => SecureRandom.uuid,
          "variables" => {
            "sip_from_host" => "103.9.189.2"
          }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema("api_errors")
      expect(json_response(body).fetch("more_info")).to match(%r{https://twilreapi.somleng.org/dashboard/logs/})
    end
  end
end
