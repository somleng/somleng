class NoCustomDomainConstraint
  def matches?(request)
    request.host == request.headers.fetch("HOST")
  end
end
