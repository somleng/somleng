require "rails_helper"

RSpec.describe SIPTrunk do
  it "handles ACL" do
    create(:inbound_source_ip_address, ip: "2.2.2.2", region: "helium")
    sip_trunk = build(:sip_trunk, region: "hydrogen", inbound_source_ips: [ "96.9.66.256", "1.1.1.1", "1.1.1.1", "2.2.2.2", "3.3.3.3" ])
    expect(sip_trunk.inbound_source_ips).to eq([ "1.1.1.1", "2.2.2.2", "3.3.3.3" ])

    sip_trunk.save!

    expect(SIPTrunk.find(sip_trunk.id).inbound_source_ips).to eq([ "1.1.1.1", "2.2.2.2", "3.3.3.3" ])

    sip_trunk.inbound_source_ips = [ "1.1.1.1" ]
    sip_trunk.save!

    expect(SIPTrunk.find(sip_trunk.id).inbound_source_ips).to eq([ "1.1.1.1" ])
    expect(InboundSourceIPAddress.count).to eq(3)
    expect(InboundSourceIPAddress.find_by(ip: "1.1.1.1").region).to eq("hydrogen")
    expect(InboundSourceIPAddress.find_by(ip: "2.2.2.2").region).to eq("helium")
    expect(InboundSourceIPAddress.find_by(ip: "3.3.3.3").region).to eq("hydrogen")
  end

  describe "#configured_for_outbound_dialing?" do
    it "returns true for sip trunks configured for outbound dialing" do
      client_credentials_sip_trunk = build_stubbed(:sip_trunk, :client_credentials_authentication)
      ip_address_sip_trunk = build_stubbed(:sip_trunk, :ip_address_authentication)
      unconfigured_sip_trunk = build_stubbed(:sip_trunk, :ip_address_authentication, outbound_host: nil)

      expect(client_credentials_sip_trunk.configured_for_outbound_dialing?).to eq(true)
      expect(ip_address_sip_trunk.configured_for_outbound_dialing?).to eq(true)
      expect(unconfigured_sip_trunk.configured_for_outbound_dialing?).to eq(false)
    end
  end

  it "generates client credentials" do
    sip_trunk = build(:sip_trunk, :client_credentials_authentication)

    sip_trunk.save!

    expect(sip_trunk.username).to be_present
    expect(sip_trunk.password.length).to eq(24)
  end

  it "handles duplicate usernames" do
    existing_sip_trunk = create(:sip_trunk, :client_credentials_authentication)
    fake_username_generator = instance_double(UsernameGenerator)
    unique_username = UsernameGenerator.new.random_username
    allow(fake_username_generator).to receive(:random_username).and_return(
      existing_sip_trunk.username, unique_username
    )

    sip_trunk = build(
      :sip_trunk,
      :client_credentials_authentication,
      username_generator: fake_username_generator
    )

    sip_trunk.save!

    expect(sip_trunk.username).to eq(unique_username)
  end

  it "handles switching to ip address authentication mode" do
    sip_trunk = create(
      :sip_trunk,
      :client_credentials_authentication,
      username: "username",
      password: "password"
    )
    sip_trunk.update!(authentication_mode: :ip_address)

    expect(sip_trunk.username).to eq(nil)
    expect(sip_trunk.password).to eq(nil)
  end
end
