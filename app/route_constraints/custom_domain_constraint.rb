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
    request = request.dup.extend(HostAuthorityRequest)
    host == request.hostname
  end
end
