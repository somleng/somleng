class URLValidator
  attr_reader :options

  BAD_HOSTS = [ "localhost" ].freeze

  def initialize(options = {})
    @options = options
  end

  def valid?(value)
    return true if value.blank? && options[:allow_blank]
    return false unless format.match?(value)

    uri = URI.parse(value)
    return false if BAD_HOSTS.include?(uri.host)

    ip_address = IPAddr.new(uri.host)
    return false unless valid_public_ip?(ip_address)

    true
  rescue IPAddr::InvalidAddressError
    true
  end

  private

  def format
    @format ||= options.fetch(:format) { /\A#{URI::DEFAULT_PARSER.make_regexp(allowed_schemes)}\z/ }
  end

  def allowed_schemes
    allowed_schemes = options.fetch(:schemes, [ "https" ])
    allowed_schemes << "http" if options[:allow_http]
    allowed_schemes
  end

  def valid_public_ip?(ip)
    return false unless ip.ipv4?
    return false if ip.loopback?
    return false if ip.private?

    true
  end
end
