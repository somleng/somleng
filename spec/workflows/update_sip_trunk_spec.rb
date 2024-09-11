require "rails_helper"

RSpec.describe UpdateSIPTrunk do
  it "revokes the old and authorizes the new source IP" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      inbound_source_ip: "175.100.7.240",
      region: :hydrogen
    )
    sip_trunk.update!(inbound_source_ip: "175.100.7.241")

    UpdateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:remove_permission).with(
      IPAddr.new("175.100.7.240"),
    )
    expect(fake_call_service_client).to have_received(:add_permission).with(
      IPAddr.new("175.100.7.241"),
      group_id: 1
    )
  end

  it "updates the source IP permission on region change" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      region: :hydrogen,
      inbound_source_ip: "175.100.7.240"
    )
    sip_trunk.update!(region: :helium)

    UpdateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:update_permission).with(
      sip_trunk.inbound_source_ip,
      group_id: 2
    )
  end

  it "handles changing to IP address authentication mode" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :client_credentials_authentication,
      region: :hydrogen,
      username: "username"
    )
    sip_trunk.update!(authentication_mode: :ip_address, inbound_source_ip: "175.100.7.240")

    UpdateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:delete_subscriber).with(username: "username")
    expect(fake_call_service_client).to have_received(:add_permission).with(sip_trunk.inbound_source_ip, group_id: 1)
  end

  it "handles changing to Client Credentials authentication mode" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :ip_address_authentication,
      region: :hydrogen,
      inbound_source_ip: "175.100.7.240"
    )
    sip_trunk.update!(authentication_mode: :client_credentials, inbound_source_ip: nil, username: "username", password: "password")

    UpdateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:remove_permission).with(IPAddr.new("175.100.7.240"))
    expect(fake_call_service_client).to have_received(:create_subscriber).with(username: "username", password: "password")
  end

  def build_fake_call_service_client
    instance_spy(CallService::Client)
  end
end
