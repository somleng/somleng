class ProxySubdomainConstraint
  attr_reader :subdomain

  def initialize(subdomain)
    @subdomain = subdomain
  end

  def matches?(request)
    request_subdomain = ActionDispatch::Http::URL.extract_subdomain(
      request.headers.fetch("HOST"),
      1
    )

    request_subdomain == subdomain
  end
end
