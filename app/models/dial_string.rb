class DialString
  attr_reader :sip_trunk, :destination

  def initialize(sip_trunk:, destination:)
    @sip_trunk = sip_trunk
    @destination = destination
  end

  def to_s
    result = build_dial_string
    result.prepend("+") if sip_trunk.outbound_plus_prefix?
    result
  end

  private

  def build_dial_string
    result = sip_trunk.outbound_national_dialing? ? Phony.format(destination, format: :national, spaces: "") : destination

    "#{sip_trunk.outbound_dial_string_prefix}#{result}@#{sip_trunk.outbound_host}"
  end
end
