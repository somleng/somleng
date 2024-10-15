require "rails_helper"

RSpec.describe SIPTrunkResolver do
  it "returns the SIP trunk if only one exists for the source IP" do
    sip_trunk = create(:sip_trunk, inbound_source_ips: [ "89.0.142.86", "89.0.142.87" ])
    resolver = SIPTrunkResolver.new

    expect(resolver.find_sip_trunk_by(source_ip: "89.0.142.86")).to eq(sip_trunk)
    expect(resolver.find_sip_trunk_by(source_ip: "89.0.142.87")).to eq(sip_trunk)
    expect(resolver.find_sip_trunk_by(source_ip: "89.0.142.88")).to eq(nil)
  end

  it "returns the first SIP trunk if multiple exist for the source IP belonging to the same carrier" do
    carrier = create(:carrier)
    sip_trunk1 = create(:sip_trunk, carrier:, inbound_source_ips: "89.0.142.86")
    _sip_trunk2 = create(:sip_trunk, carrier:, inbound_source_ips: "89.0.142.86")
    resolver = SIPTrunkResolver.new

    expect(resolver.find_sip_trunk_by(source_ip: "89.0.142.86")).to eq(sip_trunk1)
  end

  it "uses the destination number to find a SIP trunk if multiple exist for the source IP belonging to different carriers" do
    carrier1 = create(:carrier)
    carrier2 = create(:carrier)
    _sip_trunk_1 = create(:sip_trunk, carrier: carrier1, inbound_source_ips: "89.0.142.86")
    sip_trunk2 = create(:sip_trunk, carrier: carrier2, inbound_source_ips: "89.0.142.86")
    create(:phone_number, number: "12513095500", carrier: carrier2)
    resolver = SIPTrunkResolver.new

    expect(resolver.find_sip_trunk_by(source_ip: "89.0.142.86", destination_number: "12513095500")).to eq(sip_trunk2)
    expect(resolver.find_sip_trunk_by(source_ip: "89.0.142.86", destination_number: "12513095501")).to eq(nil)
  end

  it "returns the first SIP trunk if multiple exist for the source IP belonging to different carriers" do
    carrier1 = create(:carrier)
    carrier2 = create(:carrier)
    sip_trunk1 = create(:sip_trunk, carrier: carrier1, inbound_country_code: "KH", inbound_source_ips: "89.0.142.86")
    _sip_trunk2 = create(:sip_trunk, carrier: carrier2, inbound_country_code: "KH", inbound_source_ips: "89.0.142.86")
    create(:phone_number, number: "855715100888", carrier: carrier1)
    create(:phone_number, number: "855715100888", carrier: carrier2)
    resolver = SIPTrunkResolver.new

    expect(resolver.find_sip_trunk_by(source_ip: "89.0.142.86", destination_number: "0715100888")).to eq(sip_trunk1)
  end
end
