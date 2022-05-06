class CustomDomainSubdomainConstraint
  class Request < SimpleDelegator
    # https://github.com/rack/rack/blob/main/lib/rack/request.rb#L343
    def host_authority_name
      __getobj__.send(:split_authority, host_authority)[1]
    end
  end

  attr_reader :host

  def initialize(host:)
    @host = host
  end

  def matches?(request)
    request = Request.new(request)
    request_host = request.host_authority_name
    request_subdomain = extract_subdomain(request_host)
    request_host == host && request_subdomain == host_subdomain
  end

  private

  def host_subdomain
    extract_subdomain(host)
  end

  def extract_subdomain(host)
    ActionDispatch::Http::URL.extract_subdomains(host, 1).first
  end
end
