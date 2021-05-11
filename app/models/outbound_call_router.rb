class OutboundCallRouter
  attr_reader :account, :destination

  class UnsupportedGatewayError < StandardError; end

  def initialize(account:, destination:)
    @account = account
    @destination = Phony.normalize(destination)
  end

  def routing_instructions
    raise UnsupportedGatewayError unless calling_code_allowed?

    sip_trunk = find_sip_trunk
    raise UnsupportedGatewayError if sip_trunk.blank?

    destination_number = sip_trunk.trunk_prefix? ? Phony.format(destination, format: :national, spaces: "") : destination
    dial_string = "#{sip_trunk.dial_string_prefix}#{destination_number}@#{sip_trunk.host}"

    {
      "dial_string" => dial_string
    }
  end

  private

  def calling_code_allowed?
    return true if account.allowed_calling_codes.empty?

    account.allowed_calling_codes.include?(Phony.split(destination)[0])
  end

  def find_sip_trunk
    return account.outbound_sip_trunk if account.outbound_sip_trunk.present?

    account.carrier.outbound_sip_trunks.sort_by { |sip_trunk| -sip_trunk.route_prefixes.length }.detect do |sip_trunk|
      sip_trunk.route_prefixes.any? { |prefix| destination =~ /\A#{prefix}/ } || sip_trunk.route_prefixes.empty?
    end
  end
end
