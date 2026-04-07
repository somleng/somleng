module Services
  class CallHeartbeatsRequestSchema < ServicesRequestSchema
    params do
      required(:_root).value(:array, min_size?: 1).each(:string)
    end
  end
end
