class SMSGatewayResolver
  attr_reader :carrier, :destination

  def initialize(carrier:, destination:)
    @carrier = carrier
    @destination = destination
  end

  def resolve
    return [default_sms_gateway, nil] if carrier.sms_gateway_channel_groups.empty?
    return if matched_route_prefix.blank? && fallback_channel_group.blank?

    channel_group = matched_route_prefix.present? ? find_channel_group(matched_route_prefix) : fallback_channel_group

    [channel_group.sms_gateway, channel_group.channels.sample]
  end

  private

  def find_channel_group(route_prefix)
    channel_groups.detect { |group| group.route_prefixes.include?(route_prefix) }
  end

  def matched_route_prefix
    @matched_route_prefix ||= channel_groups
                              .flat_map(&:route_prefixes)
                              .sort_by(&:length)
                              .reverse
                              .detect { |prefix| destination =~ /\A#{prefix}/ }
  end

  def fallback_channel_group
    @fallback_channel_group ||= channel_groups.find_by(route_prefixes: [])
  end

  def channel_groups
    carrier.sms_gateway_channel_groups
  end

  def default_sms_gateway
    SMSGateway.find_by(carrier_id: carrier.id)
  end
end
