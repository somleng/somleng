class DialString
  attr_reader :outbound_sip_trunk, :destination

  def initialize(outbound_sip_trunk:, destination:)
    @outbound_sip_trunk = outbound_sip_trunk
    @destination = destination
  end

  def to_s
    destination_number = outbound_sip_trunk.trunk_prefix? ? Phony.format(destination, format: :national, spaces: "") : destination
    "#{outbound_sip_trunk.dial_string_prefix}#{destination_number}@#{outbound_sip_trunk.host}"
  end
end
