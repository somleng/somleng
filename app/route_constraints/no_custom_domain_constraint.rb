class NoCustomDomainConstraint
  def matches?(request)
    !AppRequest.new(request).custom_domain_request?
  end
end
