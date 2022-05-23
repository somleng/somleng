class AppSubdomainConstraint
  def matches?(request)
    subdomain, *namespace = request.subdomains
    return false unless namespace == ["app"]

    Carrier.exists?(subdomain:)
  end
end
