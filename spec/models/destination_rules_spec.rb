require "rails_helper"

RSpec.describe DestinationRules do
  describe "#find_sip_trunk" do
    it "returns the sip trunk configured for the account" do
      carrier = create(:carrier)
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier)
      _other_sip_trunk = create(:outbound_sip_trunk, carrier: carrier)
      account = create(:account, carrier: carrier, outbound_sip_trunk: sip_trunk)

      result = DestinationRules.new(
        account: account,
        destination: "855715100970"
      ).find_sip_trunk

      expect(result).to eq(sip_trunk)
    end

    it "returns the first sip trunk of the carrier" do
      carrier = create(:carrier)
      sip_trunk = create(:outbound_sip_trunk, carrier: carrier)
      account = create(:account, carrier: carrier)

      result = DestinationRules.new(
        account: account,
        destination: "855715100970"
      ).find_sip_trunk

      expect(result).to eq(sip_trunk)
    end

    it "handles prefix routing" do
      carrier = create(:carrier)
      _catch_all_sip_trunk = create(:outbound_sip_trunk, carrier: carrier)
      sip_trunk = create(
        :outbound_sip_trunk,
        carrier: carrier,
        route_prefixes: ["85571"]
      )
      account = create(:account, carrier: carrier)

      result = DestinationRules.new(
        account: account,
        destination: "855715100970"
      ).find_sip_trunk

      expect(result).to eq(sip_trunk)
    end

    it "returns nil when no route is found" do
      carrier = create(:carrier)
      _sip_trunk = create(
        :outbound_sip_trunk,
        carrier: carrier,
        route_prefixes: ["85512"]
      )
      account = create(:account, carrier: carrier)

      result = DestinationRules.new(account: account, destination: "855715100970").find_sip_trunk

      expect(result).to eq(nil)
    end
  end

  describe "#calling_code_allowed?" do
    it "returns true if the account allows the dialing code" do
      carrier = create(:carrier)
      account = create(:account, carrier: carrier, allowed_calling_codes: ["61"])
      unconfigured_account = create(:account, carrier: carrier)

      expect(
        DestinationRules.new(
          account: account,
          destination: "855715100970"
        ).calling_code_allowed?
      ).to eq(false)

      expect(
        DestinationRules.new(
          account: account,
          destination: "61434333222"
        ).calling_code_allowed?
      ).to eq(true)

      expect(
        DestinationRules.new(
          account: unconfigured_account,
          destination: "61434333222"
        ).calling_code_allowed?
      ).to eq(true)
    end
  end
end
