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
    find_sip_trunk_by_route_prefix(outbound_sip_trunks) || outbound_sip_trunks.detect { |sip_trunk| sip_trunk.outbound_route_prefixes.blank? }
  end

  def find_sip_trunk_by_route_prefix(sip_trunks)
    sip_trunk_route_prefixes = sip_trunks.select(&:outbound_route_prefixes?).flat_map do |sip_trunk|
      sip_trunk.outbound_route_prefixes.map { |prefix| [ sip_trunk, prefix ] }
    end

    longest_prefix_first = sip_trunk_route_prefixes.sort_by { |(_, prefix)| -prefix.length }
    longest_prefix_first.detect do |(sip_trunk, prefix)|
      return sip_trunk if destination =~ /\A#{prefix}/
    end
  end
end
