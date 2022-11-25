class SMSGatewayResolver
  class LoadBalancer
    def select_channel(channels)
      channels.sample
    end
  end

  attr_reader :load_balancer

  def initialize(load_balancer: LoadBalancer.new)
    @load_balancer = load_balancer
  end

  def resolve(carrier:, destination:)
    channel_groups = carrier.sms_gateway_channel_groups
    return SMSGateway.find_by(carrier_id: carrier.id) if channel_groups.empty?

    channel_group = find_channel_group(channel_groups, destination)

    return if channel_group.blank?

    [channel_group.sms_gateway, select_channel(channel_group)]
  end

  private

  def find_channel_group(channel_groups, destination)
    route_prefixes = route_prefixes(channel_groups).sort_by { |prefix, _| -prefix.length }
    route_prefix = route_prefixes.detect { |prefix, _| destination =~ /\A#{prefix}/ }
    route_prefix&.last || channel_groups.find_by(route_prefixes: [])
  end

  def route_prefixes(channel_groups)
    channel_groups.each_with_object({}) do |channel_group, result|
      channel_group.route_prefixes.each do |route_prefix|
        result[route_prefix] = channel_group
      end
    end
  end

  def select_channel(channel_group)
    load_balancer.select_channel(channel_group.channels)&.slot_index
  end
end
