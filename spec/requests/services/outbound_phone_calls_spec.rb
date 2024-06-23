require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/outbound_phone_calls" do
    it "creates a new outbound call" do
      carrier = create(:carrier)
      sip_trunk = create(
        :sip_trunk,
        carrier:,
        outbound_symmetric_latching_supported: true,
        outbound_host: "27.109.112.141",
        outbound_route_prefixes: [ "85516" ]
      )
      create(
        :sip_trunk,
        carrier:,
        outbound_symmetric_latching_supported: false,
        outbound_host: "175.100.7.240",
        outbound_route_prefixes: [ "85571" ]
      )
      account = create(:account, carrier:)
      parent_phone_call = create(:phone_call, :inbound, :answered, account:, sip_trunk:)

      post(
        api_services_outbound_phone_calls_path,
        params: {
          destinations: [ "+855 16 701 721", "+855 715 100 722" ],
          parent_call_sid: parent_phone_call.id
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/outbound_phone_calls")
      phone_calls_response = json_response(response.body).fetch("phone_calls")
      expect(phone_calls_response.size).to eq(2)
      expect(phone_calls_response[0]).to include(
        "parent_call_sid" => parent_phone_call.id,
        "to" => "+85516701721",
        "symmetric_latching" => true,
        "host" => "27.109.112.141"
      )
      expect(phone_calls_response[1]).to include(
        "parent_call_sid" => parent_phone_call.id,
        "to" => "+855715100722",
        "symmetric_latching" => false,
        "host" => "175.100.7.240"
      )
    end

    it "handles an unsupported number" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      sip_trunk = create(:sip_trunk, carrier:, outbound_route_prefixes: [ "85512" ])
      parent_phone_call = create(:phone_call, :inbound, :answered, account:, sip_trunk:)

      post(
        api_services_outbound_phone_calls_path,
        params: {
          destinations: [ "+855 16 701 721" ],
          parent_call_sid: parent_phone_call.id
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
    end
  end
end
