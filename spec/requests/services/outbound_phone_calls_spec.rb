require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/outbound_phone_calls" do
    it "creates a new outbound call" do
      carrier = create(:carrier)
      sip_trunk = create(
        :sip_trunk,
        carrier:,
        sip_profile: "nat_gateway",
        outbound_host: "27.109.112.141",
        outbound_route_prefixes: [ "85516" ],
        outbound_national_dialing: true
      )
      create(
        :sip_trunk,
        carrier:,
        sip_profile: "test",
        outbound_host: "175.100.7.240",
        outbound_route_prefixes: [ "85571" ],
        outbound_national_dialing: false
      )
      account = create(:account, carrier:)
      parent_phone_call = create(:phone_call, :inbound, :answered, account:, sip_trunk:, to: "2442")

      post(
        api_services_outbound_phone_calls_path,
        params: {
          destinations: [ "+855 16 701 721", "+855 715 100 722", " sip:example.com:5080 " ],
          parent_call_sid: parent_phone_call.id
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/outbound_phone_calls")
      phone_calls_response = json_response(response.body).fetch("phone_calls")
      expect(phone_calls_response.size).to eq(3)
      expect(phone_calls_response[0]).to include(
        "parent_call_sid" => parent_phone_call.id,
        "from" => "2442",
        "routing_parameters" => include(
          "sip_profile" => "nat_gateway",
          "host" => "27.109.112.141",
          "national_dialing" => true
        )
      )
      expect(phone_calls_response[1]).to include(
        "parent_call_sid" => parent_phone_call.id,
        "from" => "2442",
        "routing_parameters" => include(
          "sip_profile" => "test",
          "host" => "175.100.7.240",
          "national_dialing" => false
        )
      )
      expect(phone_calls_response[2]).to include(
        "parent_call_sid" => parent_phone_call.id,
        "from" => "2442",
        "routing_parameters" => nil,
        "address" => "example.com:5080"
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
