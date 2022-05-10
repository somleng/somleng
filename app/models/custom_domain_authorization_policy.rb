class CustomDomainAuthorizationPolicy
  attr_reader :carrier, :host, :context

  def initialize(carrier:, host:, context:)
    @carrier = carrier
    @host = host
    @context = context
  end

  def authorized?
    carrier_from_domain = Carrier.from_domain(host:, type: context)
    return true if carrier_from_domain.blank?
    return true if carrier_from_domain == carrier

    false
  end
end
