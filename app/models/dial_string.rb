class DialString
  attr_reader :sip_trunk, :destination

  def initialize(sip_trunk:, destination:)
    @sip_trunk = sip_trunk
    @destination = destination
  end

  def to_s
    result = sip_trunk.outbound_trunk_prefix? ? Phony.format(destination, format: :national, spaces: "") : destination
    result = "#{sip_trunk.outbound_dial_string_prefix}#{result}@#{sip_trunk.outbound_host}"
    result.prepend("+") if sip_trunk.outbound_plus_prefix?
    result
  end
end
