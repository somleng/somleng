require "rails_helper"

RSpec.describe SIPTrunk do
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

  it "resets the client credentials" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :client_credentials_authentication,
      call_service_client: fake_call_service_client
    )

    sip_trunk.update!(authentication_mode: :ip_address)

    expect(sip_trunk.username).to eq(nil)
    expect(sip_trunk.password).to eq(nil)
    expect(fake_call_service_client.subscribers.size).to eq(0)
  end

  it "creates a subscriber" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = build(
      :sip_trunk,
      :client_credentials_authentication,
      call_service_client: fake_call_service_client
    )

    sip_trunk.save!

    expect(fake_call_service_client.subscribers.size).to eq(1)
  end

  it "deletes a subscriber" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      :client_credentials_authentication,
      call_service_client: fake_call_service_client
    )

    sip_trunk.destroy!

    expect(fake_call_service_client.subscribers.size).to eq(0)
  end

  it "revokes the source IP on destroy" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      inbound_source_ip: "175.100.7.240",
      call_service_client: fake_call_service_client
    )

    sip_trunk.destroy!

    expect(fake_call_service_client.ip_addresses).to be_empty
  end

  it "authorizes the source IP on create" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = build(
      :sip_trunk,
      region: "hydrogen",
      inbound_source_ip: "175.100.7.240",
      call_service_client: fake_call_service_client
    )

    sip_trunk.save!

    expect(fake_call_service_client.ip_addresses).to eq(
      IPAddr.new("175.100.7.240") => [ { group_id: 1 } ]
    )
  end

  it "revokes the old and authorizes the new source IP on update" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      inbound_source_ip: "175.100.7.240",
      call_service_client: fake_call_service_client
    )

    sip_trunk.update!(inbound_source_ip: "175.100.7.241")

    expect(fake_call_service_client.ip_addresses.keys).to eq([ "175.100.7.241" ])
  end

  it "handles switching to client credentials authorization mode" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      inbound_source_ip: "175.100.7.240",
      call_service_client: fake_call_service_client
    )

    sip_trunk.update!(inbound_source_ip: nil)

    expect(fake_call_service_client.ip_addresses).to eq({})
  end

  it "handles switching to ip address authorization mode" do
    fake_call_service_client = build_fake_call_service_client
    sip_trunk = create(
      :sip_trunk,
      inbound_source_ip: nil,
      call_service_client: fake_call_service_client
    )

    sip_trunk.update!(inbound_source_ip: "175.100.7.240")

    expect(fake_call_service_client.ip_addresses.keys).to eq([ "175.100.7.240" ])
  end

  def build_fake_call_service_client
    klass = Class.new do
      attr_reader :subscribers, :ip_addresses

      def initialize
        @subscribers = []
        @ip_addresses = {}
      end

      def create_subscriber(username:, password:)
        _password = password
        subscribers << username
      end

      def delete_subscriber(username:)
        subscribers.delete(username)
      end

      def add_permission(ip, *args)
        ip_addresses[ip] = args
      end

      def remove_permission(ip)
        ip_addresses.delete(ip)
      end
    end

    klass.new
  end
end
