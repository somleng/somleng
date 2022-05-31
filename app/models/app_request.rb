class AppRequest
  attr_reader :request

  def initialize(request)
    @request = ActionDispatch::Request.new(request.env.except("HTTP_X_FORWARDED_HOST"))
  end

  def carrier_subdomain_request?
    _subdomain, *namespace = request.subdomains
    namespace == ["app"]
  end

  def find_carrier
    Carrier.find_by(subdomain: carrier_subdomain) if carrier_subdomain_request?
  end

  def find_carrier!
    raise ActiveRecord::RecordNotFound unless carrier_subdomain_request?

    Carrier.find_by!(subdomain: carrier_subdomain)
  end

  def carrier_subdomain
    request.subdomains.first
  end
end
