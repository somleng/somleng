class CallRouter
  DEFAULT_TRUNK_PREFIX = "0".freeze

  attr_accessor :source, :destination,
                :trunk_prefix, :trunk_prefix_replacement, :source_matcher

  def initialize(options = {})
    self.source = options[:source]
    self.destination = options[:destination]
    self.trunk_prefix = options.fetch(:trunk_prefix, DEFAULT_TRUNK_PREFIX)
    self.trunk_prefix_replacement = options[:trunk_prefix_replacement]
    self.source_matcher = options[:source_matcher]
  end

  def normalized_source
    sanitized_source = sanitize_phone_number(source)
    return sanitized_source if source.blank? || trunk_prefix_replacement.blank?
    return sanitized_source if sanitized_source.starts_with?(trunk_prefix_replacement)

    sanitized_source.sub(/\A(?:#{trunk_prefix})?/, "").prepend(trunk_prefix_replacement)
  end

  def routing_instructions
    normalized_destination = Phony.normalize(destination)

    destination_gateways = Torasup::PhoneNumber.new(
      normalized_destination
    ).operator.gateways || {}

    default_destination_gateway = destination_gateways["default"]
    source_lookup = modified_source

    gateway_config = destination_gateways[source_lookup] || default_destination_gateway || default_gateway
    gateway_host = gateway_config["host"]
    prefix_config = gateway_config["prefix"]

    return { "disable_originate" => "1" } if gateway_host.blank?

    address = if prefix_config == false
                Phony.format(normalized_destination, format: :national, spaces: "")
              elsif prefix_config == "+"
                Phony.format(normalized_destination, format: :+, spaces: "")
              else
                normalized_destination
              end

    {
      "source" => gateway_config.fetch("caller_id") { source_lookup },
      "destination" => normalized_destination,
      "dial_string_path" => "external/#{address}@#{gateway_host}"
    }
  end

  private

  def sanitize_phone_number(phone_number)
    phone_number.sub(/\A\+*/, "")
  end

  def default_gateway
    gateway_settings = Rails.configuration.app_settings[:default_sip_gateway]

    return {} if gateway_settings.blank?
    return {} if gateway_settings["enabled"].blank?

    gateway_settings
  end

  def modified_source
    return source if source.blank? || source_matcher.blank?

    source.match(Regexp.new(source_matcher))[1]
  end
end
