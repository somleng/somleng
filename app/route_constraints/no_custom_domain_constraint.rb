class NoCustomDomainConstraint
  attr_reader :host

  def matches?(request)
    request.host == request.headers.fetch("HOST")
  end
end
