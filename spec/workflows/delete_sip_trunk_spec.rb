require "rails_helper"

RSpec.describe DeleteSIPTrunk do
  it "revokes the source IP" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      inbound_source_ip: "175.100.7.240"
    )
    sip_trunk.destroy!

    DeleteSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:remove_permission).with(
      sip_trunk.inbound_source_ip
    )
  end

  it "deletes a subscriber" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :client_credentials_authentication,
      username: "username"
    )
    sip_trunk.destroy!

    DeleteSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:delete_subscriber).with(
      username: "username"
    )
  end

  def build_fake_call_service_client
    instance_spy(CallService::Client)
  end
end
