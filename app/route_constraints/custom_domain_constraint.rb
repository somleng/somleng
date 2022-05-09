class CustomDomainConstraint
  attr_reader :host

  module HostAuthorityRequest
    def authority
      host_authority
    end
  end

  def initialize(host:)
    @host = host
  end

  def matches?(request)
    request.extend(HostAuthorityRequest)
    host == request.hostname
  end
end
