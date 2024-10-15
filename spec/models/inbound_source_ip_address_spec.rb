require "rails_helper"

RSpec.describe InboundSourceIPAddress do
  it "has scopes to return in_use and unused records" do
    unused = create(:inbound_source_ip_address)
    in_use = create(:inbound_source_ip_address)
    create(:sip_trunk, inbound_source_ips: in_use.ip)

    expect(InboundSourceIPAddress.in_use).to contain_exactly(in_use)
    expect(InboundSourceIPAddress.unused).to contain_exactly(unused)
  end

  it "authorizes the source IP on create" do
    fake_call_service_client = build_fake_call_service_client
    inbound_source_ip_address = build(
      :inbound_source_ip_address,
      ip: "175.100.7.240",
      region: "hydrogen",
      call_service_client: fake_call_service_client
    )

    inbound_source_ip_address.save!

    expect(fake_call_service_client).to have_received(:add_permission).with(
      IPAddr.new("175.100.7.240"),
      group_id: 1
    )
  end

  it "revokes the source IP on destroy" do
    fake_call_service_client = build_fake_call_service_client
    inbound_source_ip_address = create(
      :inbound_source_ip_address,
      ip: "175.100.7.240",
      call_service_client: fake_call_service_client
    )

    inbound_source_ip_address.destroy!

    expect(fake_call_service_client).to have_received(:remove_permission).with(
      IPAddr.new("175.100.7.240")
    )
  end

  def build_fake_call_service_client
    instance_spy(CallService::Client)
  end
end
