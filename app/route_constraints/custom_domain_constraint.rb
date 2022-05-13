class CustomDomainConstraint
  attr_reader :host

  def initialize(host:)
    @host = host
  end

  def matches?(request)
    host == CustomDomainRequest.new(request).app_hostname
  end
end
