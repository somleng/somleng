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
    return default_sms_gateway(carrier) if channel_groups.empty?

    channel_group = find_channel_group(channel_groups, destination)

    return if channel_group.blank?

    [channel_group.sms_gateway, select_channel(channel_group)]
  end

  private

  def find_channel_group(channel_groups, destination)
    route_prefix = channel_groups
                   .flat_map(&:route_prefixes)
                   .sort_by(&:length)
                   .reverse
                   .detect { |prefix| destination =~ /\A#{prefix}/ }

    channel_group = channel_groups.detect { |group| group.route_prefixes.include?(route_prefix) }
    channel_group || fallback_channel_group(channel_groups)
  end

  def fallback_channel_group(channel_groups)
    channel_groups.find_by(route_prefixes: [])
  end

  def select_channel(channel_group)
    return if channel_group.channels.empty?

    load_balancer.select_channel(channel_group.channels).slot_index
  end

  def default_sms_gateway(carrier)
    SMSGateway.find_by(carrier_id: carrier.id)
  end
end
