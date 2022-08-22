require "rails_helper"

RSpec.describe InboundSIPTrunk do
  it "revokes the source IP on destroy" do
    fake_inbound_sip_trunk_authorization = build_fake_inbound_sip_trunk_authorization
    inbound_sip_trunk = create(
      :inbound_sip_trunk,
      source_ip: "175.100.7.240",
      inbound_sip_trunk_authorization: fake_inbound_sip_trunk_authorization
    )

    inbound_sip_trunk.destroy!

    expect(fake_inbound_sip_trunk_authorization.ip_addresses).to be_empty
  end

  it "authorizes the source IP on create" do
    fake_inbound_sip_trunk_authorization = build_fake_inbound_sip_trunk_authorization
    inbound_sip_trunk = build(
      :inbound_sip_trunk,
      source_ip: "175.100.7.240",
      inbound_sip_trunk_authorization: fake_inbound_sip_trunk_authorization
    )

    inbound_sip_trunk.save!

    expect(fake_inbound_sip_trunk_authorization.ip_addresses).to eq(["175.100.7.240"])
  end

  it "revokes the old and authorizes the new source IP on update" do
    fake_inbound_sip_trunk_authorization = build_fake_inbound_sip_trunk_authorization
    inbound_sip_trunk = create(
      :inbound_sip_trunk,
      source_ip: "175.100.7.240",
      inbound_sip_trunk_authorization: fake_inbound_sip_trunk_authorization
    )

    inbound_sip_trunk.update!(source_ip: "175.100.7.241")

    expect(fake_inbound_sip_trunk_authorization.ip_addresses).to eq(["175.100.7.241"])
  end

  def build_fake_inbound_sip_trunk_authorization
    klass = Class.new do
      attr_reader :ip_addresses

      def initialize
        @ip_addresses = []
      end

      def add_permission(ip)
        ip_addresses << ip
      end

      def remove_permission(ip)
        ip_addresses.delete(ip)
      end
    end

    klass.new
  end
end
