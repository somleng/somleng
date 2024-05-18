require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/outbound_phone_calls" do
    it "creates a new outbound call" do
      parent_phone_call = create(:phone_call, :inbound, :answered)

      post(
        api_services_outbound_phone_calls_path,
        params: {
          destinations: [ "+855 16 701 721", "+855 16 701 722" ],
          parent_call_sid: parent_phone_call.id
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/phone_call")
      expect(json_response(response.body)).to have_attributes(
        "destination" => "85516701721",
        "dial_string_prefix" => nil,
        "plus_prefix" => false,
        "national_dialing" => false,
        "host" => "27.109.112.141",
        "username" => nil,
        "symmetric_latching" => true
      )
    end

    it "handles an unsupported number" do
      carrier = create(:carrier)
      _sip_trunk = create(
        :sip_trunk, carrier:, outbound_host: "27.109.112.141", outbound_route_prefixes: [ "85512" ]
      )
      account = create(:account, carrier:)

      post(
        api_services_routing_parameters_path,
        params: {
          phone_number: "+81-9082702366",
          account_sid: account.id
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("501")
    end
  end
end
