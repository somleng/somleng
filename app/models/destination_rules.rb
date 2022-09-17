class DestinationRules
  attr_reader :account, :destination

  def initialize(account:, destination:)
    @account = account
    @destination = destination
  end

  def valid?
    calling_code_allowed? && sip_trunk.present?
  end

  def calling_code_allowed?
    return true if account.allowed_calling_codes.empty?

    account.allowed_calling_codes.include?(Phony.split(destination)[0])
  end

  def sip_trunk
    @sip_trunk ||= find_sip_trunk
  end

  private

  def find_sip_trunk
    return account.sip_trunk if account.sip_trunk&.configured_for_outbound_dialing?
    return if account.sip_trunk.present?

    outbound_sip_trunks = account.carrier.sip_trunks.select(&:configured_for_outbound_dialing?)
    outbound_sip_trunks = outbound_sip_trunks.sort_by do |sip_trunk|
      -sip_trunk.outbound_route_prefixes.length
    end
    outbound_sip_trunks.detect do |sip_trunk|
      sip_trunk.outbound_route_prefixes.any? { |prefix| destination =~ /\A#{prefix}/ } || sip_trunk.outbound_route_prefixes.empty?
    end
  end
end
