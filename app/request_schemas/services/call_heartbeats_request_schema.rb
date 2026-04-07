module Services
  class CallHeartbeatsRequestSchema < ServicesRequestSchema
    params do
      required(:call_ids).value(:array, min_size?: 1).each(:string)
    end
  end
end
