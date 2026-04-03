class RoutingParameters
  attr_reader :phone_call

  def initialize(phone_call)
    @phone_call = phone_call
  end

  def to_h
    {
      address: phone_call.to.sip_address,
      destination: phone_call.to.to_s,
      dial_string_prefix: sip_trunk.outbound_dial_string_prefix,
      plus_prefix: sip_trunk.outbound_plus_prefix?,
      national_dialing: sip_trunk.outbound_national_dialing?,
      host: sip_trunk.outbound_host,
      username: sip_trunk.username,
      sip_profile: sip_trunk.sip_profile
    }
  end

  private

  def sip_trunk
    phone_call.sip_trunk
  end
end
