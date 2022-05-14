require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/inbound_phone_calls" do
    it "creates a phone call" do
      carrier = create(:carrier)
      phone_number = create(
        :phone_number,
        :assigned_to_account,
        carrier:,
        number: "16189124649"
      )
      create(
        :phone_number_configuration,
        phone_number:,
        voice_url: "https://example.com/voice.xml",
        voice_method: "POST",
        status_callback_url: "https://example.com/status_callback",
        status_callback_method: "POST"
      )
      create(:inbound_sip_trunk, carrier:, source_ip: "175.100.7.240")

      post(
        services_inbound_phone_calls_path,
        params: {
          "source_ip" => "175.100.7.240",
          "to" => "16189124649",
          "from" => "16189124650",
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
        "to" => "+16189124649",
        "from" => "+16189124650",
        "voice_url" => "https://example.com/voice.xml",
        "voice_method" => "POST",
        "status_callback_url" => "https://example.com/status_callback",
        "status_callback_method" => "POST"
      )
    end
  end
end
