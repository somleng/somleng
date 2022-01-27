class DialString
  attr_reader :outbound_sip_trunk, :destination

  def initialize(outbound_sip_trunk:, destination:)
    @outbound_sip_trunk = outbound_sip_trunk
    @destination = destination
  end

  def to_s
    result = outbound_sip_trunk.trunk_prefix? ? Phony.format(destination, format: :national, spaces: "") : destination
    result = "#{outbound_sip_trunk.dial_string_prefix}#{result}@#{outbound_sip_trunk.host}"
    result.prepend("+") if outbound_sip_trunk.plus_prefix?
    result
  end
end
