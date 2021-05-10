require "rails_helper"

RSpec.describe OutboundCallRouter do
  describe "#routing_instructions" do
    it "returns the sip trunk configured for the account" do
      carrier = create(:carrier)
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "96.9.66.131")
      _other_sip_trunk = create(:outbound_sip_trunk, carrier: carrier)
      account = create(:account, carrier: carrier, outbound_sip_trunk: sip_trunk)

      result = OutboundCallRouter.new(account: account, destination: "855715100970").routing_instructions

      expect(result).to eq("dial_string" => "855715100970@96.9.66.131")
    end

    it "returns the first sip trunk of the carrier" do
      carrier = create(:carrier)
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "96.9.66.131")
      account = create(:account, carrier: carrier)

      result = OutboundCallRouter.new(account: account, destination: "855715100970").routing_instructions

      expect(result).to eq("dial_string" => "855715100970@96.9.66.131")
    end

    it "handles prefix routing" do
      carrier = create(:carrier)
      _catch_all_sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "96.9.66.234")
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "96.9.66.131", route_prefixes: ["85571"])
      account = create(:account, carrier: carrier)

      result = OutboundCallRouter.new(account: account, destination: "855715100970").routing_instructions

      expect(result).to eq("dial_string" => "855715100970@96.9.66.131")
    end

    it "raises unsupported gateway errors" do
      carrier = create(:carrier)
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "96.9.66.131", route_prefixes: ["85512"])
      account = create(:account, carrier: carrier)

      expect {
        OutboundCallRouter.new(account: account, destination: "855715100970").routing_instructions
      }.to raise_error(OutboundCallRouter::UnsupportedGatewayError)
    end

    it "handles trunk prefix gateways" do
      carrier = create(:carrier)
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "96.9.66.131", trunk_prefix: true)
      account = create(:account, carrier: carrier)

      result = OutboundCallRouter.new(account: account, destination: "855715100970").routing_instructions

      expect(result).to eq("dial_string" => "0715100970@96.9.66.131")
    end

    it "handles dial string prefixes" do
      carrier = create(:carrier)
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier, host: "96.9.66.131", dial_string_prefix: "69980")
      account = create(:account, carrier: carrier)

      result = OutboundCallRouter.new(account: account, destination: "855715100970").routing_instructions

      expect(result).to eq("dial_string" => "69980855715100970@96.9.66.131")
    end
  end
end
