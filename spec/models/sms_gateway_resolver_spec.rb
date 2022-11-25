require "rails_helper"

RSpec.describe SMSGatewayResolver do
  describe "#resolve" do
    it "returns the default SMS gateway when no channel groups are defined" do
      default_sms_gateway = create(:sms_gateway)
      resolver = SMSGatewayResolver.new

      sms_gateway, channel = resolver.resolve(
        carrier: default_sms_gateway.carrier, destination: "85512234567"
      )

      expect(sms_gateway).to eq(default_sms_gateway)
      expect(channel).to eq(nil)
    end

    it "returns the gateway and channel with the longest matching prefix" do
      carrier = create(:carrier)
      non_matching_sms_gateway = create(:sms_gateway, carrier:)
      non_matching_channel_group = create(
        :sms_gateway_channel_group,
        sms_gateway: non_matching_sms_gateway,
        route_prefixes: ["85512"]
      )

      matching_sms_gateway = create(:sms_gateway, carrier:)
      matching_channel_group = create(
        :sms_gateway_channel_group,
        sms_gateway: matching_sms_gateway,
        route_prefixes: ["855122"]
      )
      create(
        :sms_gateway_channel,
        slot_index: 1,
        channel_group: matching_channel_group,
        sms_gateway: matching_sms_gateway
      )
      create(
        :sms_gateway_channel,
        slot_index: 2,
        channel_group: matching_channel_group,
        sms_gateway: matching_sms_gateway
      )
      create(
        :sms_gateway_channel,
        slot_index: 3,
        channel_group: non_matching_channel_group,
        sms_gateway: non_matching_sms_gateway
      )

      load_balancer = Class.new do
        def select_channel(channels)
          channels.last
        end
      end

      resolver = SMSGatewayResolver.new(load_balancer: load_balancer.new)

      sms_gateway, channel = resolver.resolve(carrier:, destination: "85512234567")

      expect(sms_gateway).to eq(matching_sms_gateway)
      expect(channel).to eq(2)
    end

    it "returns no matches when there is no matching prefix" do
      sms_gateway = create(:sms_gateway)
      create(:sms_gateway_channel_group, sms_gateway:, route_prefixes: ["85512"])
      resolver = SMSGatewayResolver.new

      result, channel = resolver.resolve(carrier: sms_gateway.carrier, destination: "85515234567")

      expect(result).to eq(nil)
      expect(channel).to eq(nil)
    end

    it "returns the fallback channel group" do
      sms_gateway = create(:sms_gateway)
      channel_group = create(:sms_gateway_channel_group, sms_gateway:, route_prefixes: [])
      create(:sms_gateway_channel, slot_index: 1, channel_group:, sms_gateway:)
      resolver = SMSGatewayResolver.new

      result, channel = resolver.resolve(carrier: sms_gateway.carrier, destination: "85515234567")

      expect(result).to eq(sms_gateway)
      expect(channel).to eq(1)
    end
  end
end
