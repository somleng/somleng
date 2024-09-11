require "rails_helper"

RSpec.describe CreateSIPTrunk do
  it "authorizes the source IP" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      region: :hydrogen,
      inbound_source_ip: "175.100.7.240"
    )

    CreateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:add_permission).with(
      sip_trunk.inbound_source_ip,
      group_id: 1
    )
  end

  it "creates a subscriber" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :client_credentials_authentication,
      username: "username",
      password: "password"
    )

    CreateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:create_subscriber).with(
      username: "username",
      password: "password"
    )
  end

  def build_fake_call_service_client
    instance_spy(CallService::Client)
  end
end
