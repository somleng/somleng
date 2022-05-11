class CustomDomainConstraint
  attr_reader :host

  def initialize(host:)
    @host = host
  end

  def matches?(request)
    request = ActionDispatch::Request.new(request.env.except("HTTP_X_FORWARDED_HOST"))
    host == request.hostname
  end
end
