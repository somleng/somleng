class AppRequest
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def carrier_subdomain_request?
    _subdomain, *namespace = request.subdomains
    namespace == ["app"]
  end

  def find_carrier
    Carrier.find_by(subdomain: carrier_subdomain) if carrier_subdomain_request?
  end

  def find_carrier!
    Carrier.find_by!(subdomain: carrier_subdomain)
  end

  private

  def carrier_subdomain
    request.subdomains.first
  end
end