require "rails_helper"

RSpec.describe UpdateSIPTrunk do
  it "handles changing to IP address authentication mode" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :client_credentials_authentication,
      region: :hydrogen,
      username: "username"
    )
    sip_trunk.update!(authentication_mode: :ip_address, inbound_source_ips: "175.100.7.240")

    UpdateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:delete_subscriber).with(username: "username")
  end

  it "handles changing to Client Credentials authentication mode" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :ip_address_authentication,
      region: :hydrogen,
      inbound_source_ips: "175.100.7.240"
    )
    sip_trunk.update!(authentication_mode: :client_credentials, inbound_source_ips: nil, username: "username", password: "password")

    UpdateSIPTrunk.call(sip_trunk, call_service_client: fake_call_service_client)

    expect(fake_call_service_client).to have_received(:create_subscriber).with(username: "username", password: "password")
  end

  def build_fake_call_service_client
    instance_spy(CallService::Client)
  end
end
