class CallRouter
  DEFAULT_TRUNK_PREFIX = "0".freeze

  attr_accessor :source, :destination,
                :trunk_prefix, :trunk_prefix_replacement, :source_matcher

  def initialize(options = {})
    self.source = fetch_option(options, :source, fetch_env: false)
    self.destination = fetch_option(options, :destination, fetch_env: false)
    self.trunk_prefix = fetch_option(options, :trunk_prefix) { DEFAULT_TRUNK_PREFIX }
    self.trunk_prefix_replacement = fetch_option(options, :trunk_prefix_replacement)
    self.source_matcher = fetch_option(options, :source_matcher)
  end

  def normalized_source
    return source if source.nil? || trunk_prefix_replacement.nil?

    source.sub(/\A((\+)?#{trunk_prefix})/, "\\2#{trunk_prefix_replacement}")
  end

  def routing_instructions
    routing_instructions = {}

    normalized_destination = Phony.normalize(destination)
    destination_gateways = Torasup::PhoneNumber.new(
      normalized_destination
    ).operator.gateways || {}

    default_gateway = fetch_gateway_config(destination_gateways, :default)
    source_lookup = modified_source
    gateway_config = destination_gateways.fetch(source_lookup) { default_gateway || {} }
    gateway_host = fetch_gateway_config(gateway_config, :host)
    address = normalized_destination

    if fetch_gateway_config(gateway_config, :prefix) == false
      address = Phony.format(address, format: :national, spaces: "")
    end

    dial_string_path = "external/#{address}@#{gateway_host}" if gateway_host

    routing_instructions["source"] = fetch_gateway_config(gateway_config, :caller_id) || source_lookup
    routing_instructions["destination"] = normalized_destination

    if dial_string_path
      routing_instructions["dial_string_path"] = dial_string_path
    else
      routing_instructions["disable_originate"] = "1"
    end

    routing_instructions
  end

  private

  def fetch_option(hash, key, fetch_env: true)
    hash.fetch(key) { fetch_env && ENV.fetch("TWILREAPI_ACTIVE_CALL_ROUTER_#{key.to_s.upcase}") { yield if block_given? } }
  end

  def modified_source
    return source if source.nil? || source_matcher.nil?

    source.match(Regexp.new(source_matcher))[1]
  end

  def fetch_gateway_config(config, key)
    config.fetch(key.to_s) { nil }
  end
end
