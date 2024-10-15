require "rails_helper"

RSpec.describe RevokeSIPTrunkPermissions do
  it "revokes SIP trunk permissions" do
    revoked_ips = []
    allow_any_instance_of(CallService::Client).to receive(:remove_permission) { |_, ip| revoked_ips << ip }

    create(:inbound_source_ip_address, ip: "38.0.101.76")
    create(:inbound_source_ip_address, ip: "38.0.101.77")
    create(:sip_trunk, inbound_source_ips: [ "38.0.101.78" ])

    RevokeSIPTrunkPermissions.call

    expect(revoked_ips.map(&:to_s)).to contain_exactly("38.0.101.76", "38.0.101.77")
    expect(InboundSourceIPAddress.pluck(:ip)).to contain_exactly(IPAddr.new("38.0.101.78"))
  end
end
