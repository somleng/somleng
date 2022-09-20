class DialString
  attr_reader :sip_trunk, :destination, :call_service_client

  def initialize(sip_trunk:, destination:, call_service_client: CallService::Client.new)
    @sip_trunk = sip_trunk
    @destination = destination
    @call_service_client = call_service_client
  end

  def to_s
    result = build_dial_string
    result.prepend("+") if sip_trunk.outbound_plus_prefix?
    result
  end

  private

  def build_dial_string
    result = sip_trunk.outbound_trunk_prefix? ? Phony.format(destination, format: :national, spaces: "") : destination

    if sip_trunk.authentication_mode.ip_address?
      "#{sip_trunk.outbound_dial_string_prefix}#{result}@#{sip_trunk.outbound_host}"
    else
      call_service_client.build_client_gateway_dial_string(
        destination: result,
        username: sip_trunk.username
      )
    end
  end
end
