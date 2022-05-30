class AppSubdomainConstraint
  def matches?(request)
    AppRequest.new(request).find_carrier.present?
  end
end
