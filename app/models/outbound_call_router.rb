class OutboundCallRouter
  attr_reader :account, :destination

  class UnsupportedGatewayError < StandardError; end

  def initialize(account:, destination:)
    @account = account
    @destination = Phony.normalize(destination)
  end

  def routing_instructions
    if account.carrier.outbound_sip_trunks.any?
      sip_trunk = find_sip_trunk
      raise UnsupportedGatewayError if sip_trunk.blank?

      destination_number = sip_trunk.trunk_prefix? ? Phony.format(destination, format: :national, spaces: "") : destination
      dial_string = "#{sip_trunk.dial_string_prefix}#{destination_number}@#{sip_trunk.host}"
    else
      dial_string = GlobalCallRouter.new(destination).dial_string
    end

    {
      "dial_string" => dial_string
    }
  end

  private

  def find_sip_trunk
    return account.outbound_sip_trunk if account.outbound_sip_trunk.present?

    account.carrier.outbound_sip_trunks.sort_by { |sip_trunk| -sip_trunk.route_prefixes.length }.detect do |sip_trunk|
      sip_trunk.route_prefixes.any? { |prefix| destination =~ /\A#{prefix}/ } || sip_trunk.route_prefixes.empty?
    end
  end

  class GlobalCallRouter
    attr_reader :destination

    def initialize(destination)
      @destination = destination
    end

    def dial_string
      raise UnsupportedGatewayError if destination_gateway.blank?

      "#{destination_gateway['dial_string_prefix']}#{destination_number}@#{destination_gateway.fetch('host')}"
    end

    private

    def destination_gateway
      @destination_gateway ||= Torasup::PhoneNumber.new(destination).operator.gateway
    end

    def destination_number
      return destination unless destination_gateway["prefix"] == false

      Phony.format(destination, format: :national, spaces: "")
    end
  end
end
