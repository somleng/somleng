class SMSGatewayResolver
  attr_reader :carrier, :destination

  def initialize(carrier:, destination:)
    @carrier = carrier
    @destination = destination
  end

  def resolve
    channel = resolve_channel
    return default_sms_gateway if channel.blank?

    [channel.sms_gateway, channel.number]
  end

  private

  def resolve_channel
    channel_groups = carrier.sms_gateway_channel_groups
    channel_group = channel_groups.first

    return if channel_group.blank?

    channel_group.channels.sample
  end

  def default_sms_gateway
    SMSGateway.find_by(carrier_id: carrier.id)
  end
end
