require "rails_helper"

RSpec.describe InitiateInboundCall do
  context "when a matching incoming phone number exists" do
    it "initiates an inbound call" do
      incoming_phone_number = create(
        :incoming_phone_number,
        phone_number: "2442",
        voice_url: "https://demo.twilio.com/docs/voice.xml",
        voice_method: "GET",
        status_callback_url: "https://www.example.com/status_callback_url",
        status_callback_method: "POST",
        twilio_request_phone_number: "855973456789"
      )

      attributes = build_phone_call_attributes(
        To: "2442",
        From: "0977100860",
        Variables: {
          "sip_network_ip" => "27.109.112.80"
        }
      )
      stub_sip_host("27.109.112.80", "855")

      phone_call = InitiateInboundCall.call(attributes)

      expect(phone_call).to be_persisted
      expect(phone_call).to be_initiated
      expect(phone_call).to have_attributes(
        to: attributes.fetch(:To),
        from: "855977100860",
        variables: attributes.fetch(:Variables),
        external_id: attributes.fetch(:ExternalSid),
        incoming_phone_number: incoming_phone_number,
        account: incoming_phone_number.account,
        voice_url: incoming_phone_number.voice_url,
        voice_method: incoming_phone_number.voice_method,
        status_callback_url: incoming_phone_number.status_callback_url,
        status_callback_method: incoming_phone_number.status_callback_method,
        twilio_request_to: incoming_phone_number.twilio_request_phone_number
      )
    end
  end

  context "when a matching incoming phone number does not exist" do
    it "does not initate an inbound call" do
      attributes = build_phone_call_attributes

      phone_call = InitiateInboundCall.call(attributes)

      expect(phone_call).not_to be_persisted
      expect(phone_call.errors).to be_present
    end
  end

  def build_phone_call_attributes(attributes = {})
    attributes.reverse_merge(
      To: "2442",
      From: "855977100860",
      ExternalSid: SecureRandom.uuid,
      Variables: {
        "sip_network_ip" => "27.109.112.80"
      }
    )
  end

  def stub_sip_host(ip_address, international_dialing_code)
    SIPHost.hosts[ip_address] = instance_double(
      SIPHost, international_dialing_code: international_dialing_code
    )
  end
end
