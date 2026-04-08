module Services
  class CallHeartbeatsRequestSchema < ServicesRequestSchema
    params do
      required(:switch_proxy_identifiers).value(:array, min_size?: 1).each(:string)
    end
  end
end
