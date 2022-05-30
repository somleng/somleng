require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/dial_string" do
    it "generates a dial string" do
      carrier = create(:carrier)
      _sip_trunk = create(
        :outbound_sip_trunk,
        carrier: carrier,
        nat_supported: true,
        host: "27.109.112.141"
      )
      account = create(:account, carrier: carrier)

      post(
        api_services_dial_string_path,
        params: {
          phone_number: "+85516701721",
          account_sid: account.id
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(json_response(response.body)).to eq(
        "dial_string" => "85516701721@27.109.112.141",
        "nat_supported" => true
      )
    end

    it "handles an unsupported number" do
      carrier = create(:carrier)
      _sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "27.109.112.141", route_prefixes: ["85512"])
      account = create(:account, carrier: carrier)

      post(
        api_services_dial_string_path,
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
