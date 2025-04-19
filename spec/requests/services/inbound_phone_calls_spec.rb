require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/inbound_phone_calls" do
    it "creates a phone call" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      create(
        :incoming_phone_number,
        account:,
        number: "16189124649",
        voice_url: "https://example.com/voice.xml",
        voice_method: "POST",
        status_callback_url: "https://example.com/status_callback",
        status_callback_method: "POST"
      )
      create(:sip_trunk, carrier:, inbound_source_ips: "175.100.7.240")

      post(
        api_services_inbound_phone_calls_path,
        params: {
          "source_ip" => "175.100.7.240",
          "to" => "16189124649",
          "from" => "16189124650",
          "external_id" => SecureRandom.uuid,
          "host" => "10.10.1.13",
          "region" => "hydrogen",
          "variables" => {
            "sip_from_host" => "1.1.1.1"
          }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/inbound_phone_call")
      expect(json_response(response.body)).to include(
        "to" => "+16189124649",
        "from" => "+16189124650",
        "voice_url" => "https://example.com/voice.xml",
        "voice_method" => "POST",
        "status_callback_url" => "https://example.com/status_callback",
        "status_callback_method" => "POST",
        "default_tts_voice" => "Basic.Kal"
      )
    end

    it "handles phone numbers which aren't assigned to an account" do
      post(
        api_services_inbound_phone_calls_path,
        params: {
          "source_ip" => "175.100.7.240",
          "to" => "855716200876",
          "from" => "85512234567",
          "region" => "hydrogen",
          "external_id" => SecureRandom.uuid,
          "variables" => {
            "sip_from_host" => "1.1.1.1"
          }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema("services/api_errors")
      expect(ErrorLog.last).to have_attributes(
        carrier: nil,
        account: nil,
        error_message: "SIP trunk does not exist for 175.100.7.240"
      )
    end

    it "handles phone numbers which aren't configured" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      _unconfigured_incoming_phone_number = create(
        :incoming_phone_number, account:, number: "85568308532"
      )
      create(
        :sip_trunk,
        carrier:,
        inbound_source_ips: "175.100.7.240",
        inbound_country_code: "KH"
      )

      post(
        api_services_inbound_phone_calls_path,
        params: {
          "source_ip" => "175.100.7.240",
          "to" => "068308532",
          "from" => "012234567",
          "region" => "hydrogen",
          "external_id" => SecureRandom.uuid,
          "variables" => {
            "sip_from_host" => "1.1.1.1"
          }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema("services/api_errors")
      expect(ErrorLog.last).to have_attributes(
        carrier:,
        account: account,
        error_message: "Phone number 85568308532 is unconfigured."
      )
    end
  end
end
