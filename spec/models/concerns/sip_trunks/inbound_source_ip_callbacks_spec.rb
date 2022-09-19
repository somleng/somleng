require "rails_helper"

module SIPTrunks
  RSpec.describe InboundSourceIPCallbacks do
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
        inbound_source_ip: "175.100.7.240",
        call_service_client: fake_call_service_client
      )

      sip_trunk.save!

      expect(fake_call_service_client.ip_addresses).to eq(["175.100.7.240"])
    end

    it "revokes the old and authorizes the new source IP on update" do
      fake_call_service_client = build_fake_call_service_client
      sip_trunk = create(
        :sip_trunk,
        inbound_source_ip: "175.100.7.240",
        call_service_client: fake_call_service_client
      )

      sip_trunk.update!(inbound_source_ip: "175.100.7.241")

      expect(fake_call_service_client.ip_addresses).to eq(["175.100.7.241"])
    end

    it "handles switching to client credentials authorization mode" do
      fake_call_service_client = build_fake_call_service_client
      sip_trunk = create(
        :sip_trunk,
        inbound_source_ip: "175.100.7.240",
        call_service_client: fake_call_service_client
      )

      sip_trunk.update!(inbound_source_ip: nil)

      expect(fake_call_service_client.ip_addresses).to eq([])
    end

    it "handles switching to ip address authorization mode" do
      fake_call_service_client = build_fake_call_service_client
      sip_trunk = create(
        :sip_trunk,
        inbound_source_ip: nil,
        call_service_client: fake_call_service_client
      )

      sip_trunk.update!(inbound_source_ip: "175.100.7.240")

      expect(fake_call_service_client.ip_addresses).to eq(["175.100.7.240"])
    end

    def build_fake_call_service_client
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
end
