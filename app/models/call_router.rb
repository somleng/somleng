class CallRouter
  DEFAULT_TRUNK_PREFIX = "0".freeze

  attr_accessor :source, :destination,
                :trunk_prefix, :trunk_prefix_replacement, :source_matcher

  def initialize(options = {})
    self.source = options.fetch(:source) { nil }
    self.destination = options.fetch(:destination) { nil }
    self.trunk_prefix = options.fetch(:trunk_prefix) { DEFAULT_TRUNK_PREFIX }
    self.trunk_prefix_replacement = options.fetch(:trunk_prefix_replacement) { nil }
    self.source_matcher = options.fetch(:source_matcher) { nil }
  end

  def normalized_source
    return source if source.blank? || trunk_prefix_replacement.blank?

    source.sub(/\A((\+)?#{trunk_prefix})/, "\\2#{trunk_prefix_replacement}")
  end

  def routing_instructions
    routing_instructions = {}

    normalized_destination = Phony.normalize(destination)
    destination_gateways = Torasup::PhoneNumber.new(
      normalized_destination
    ).operator.gateways || {}

    default_gateway = destination_gateways.fetch("default") { nil }
    source_lookup = modified_source
    gateway_config = destination_gateways.fetch(source_lookup) { default_gateway || {} }
    gateway_host = gateway_config.fetch("host") { nil }
    address = normalized_destination

    if gateway_config.fetch("prefix") { nil } == false
      address = Phony.format(address, format: :national, spaces: "")
    end

    dial_string_path = "external/#{address}@#{gateway_host}" if gateway_host

    routing_instructions["source"] = gateway_config.fetch("caller_id") { source_lookup }
    routing_instructions["destination"] = normalized_destination

    if dial_string_path
      routing_instructions["dial_string_path"] = dial_string_path
    else
      routing_instructions["disable_originate"] = "1"
    end

    routing_instructions
  end

  private

  def modified_source
    return source if source.blank? || source_matcher.blank?

    source.match(Regexp.new(source_matcher))[1]
  end
end
