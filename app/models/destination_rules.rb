class DestinationRules
  attr_reader :account, :destination

  def initialize(account:, destination:)
    @account = account
    @destination = destination
  end

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
