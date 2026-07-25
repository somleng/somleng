require "rails_helper"

RSpec.describe OutboundSIPTrunkResolver do
  it "returns the sip trunk configured for the account" do
    carrier = create(:carrier)
    sip_trunk = create(:sip_trunk, carrier:)
    _other_sip_trunk = create(:sip_trunk, carrier:)
    account = create(:account, carrier:, sip_trunk:)

    result = OutboundSIPTrunkResolver.new.execute(
      account:,
      destination: "855715100970"
    )

    expect(result).to eq(sip_trunk)
  end

  it "returns the first sip trunk of the carrier" do
    carrier = create(:carrier)
    sip_trunk = create(:sip_trunk, carrier:)
    account = create(:account, carrier:)

    result = OutboundSIPTrunkResolver.new.execute(
      account:,
      destination: "855715100970"
    )

    expect(result).to eq(sip_trunk)
  end

  it "handles prefix routing" do
    carrier = create(:carrier)
    _catch_all_sip_trunk = create(:sip_trunk, carrier:)
    create(
      :sip_trunk,
      carrier:,
      outbound_route_prefixes: %w[85571 85597]
    )
    longer_route_prefix_sip_trunk = create(
      :sip_trunk,
      carrier:,
      outbound_route_prefixes: [ "8557151" ]
    )
    account = create(:account, carrier:)

    result = OutboundSIPTrunkResolver.new.execute(
      account:,
      destination: "855715100970"
    )

    expect(result).to eq(longer_route_prefix_sip_trunk)
  end

  it "returns nil when no route is found" do
    carrier = create(:carrier)
    _sip_trunk = create(
      :sip_trunk,
      carrier:,
      outbound_route_prefixes: [ "85512" ]
    )
    account = create(:account, carrier:)

    result = OutboundSIPTrunkResolver.new.execute(account:, destination: "855715100970")

    expect(result).to be_nil
  end

  it "handles unconfigured trunks" do
    carrier = create(:carrier)
    _sip_trunk = create(:sip_trunk, outbound_host: nil, carrier:)
    account = create(:account, carrier:)

    result = OutboundSIPTrunkResolver.new.execute(account:, destination: "855715100970")

    expect(result).to be_nil
  end
end
