require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/routing_parameters" do
    it "return routing parameters" do
      carrier = create(:carrier)
      _sip_trunk = create(
        :sip_trunk,
        carrier:,
        outbound_symmetric_latching_supported: true,
        outbound_host: "27.109.112.141"
      )
      account = create(:account, carrier:)

      post(
        api_services_routing_parameters_path,
        params: {
          phone_number: "+855 16 701 721",
          account_sid: account.id
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(json_response(response.body)).to eq(
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
        :sip_trunk, carrier:, outbound_host: "27.109.112.141", outbound_route_prefixes: ["85512"]
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
