module Services
  class UpdatePhoneCallRequestSchema < ServicesRequestSchema
    params do
      required(:switch_proxy_identifier).filled(:str?)
    end
  end
end
