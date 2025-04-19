module Services
  class OutboundPhoneCallsController < ServicesController
    def create
      validate_request_schema(
        with: OutboundPhoneCallsRequestSchema,
        serializer_class: OutboundPhoneCallSerializer,
        location: nil
      ) do |permitted_params|
        CreatePhoneCallsFromOutboundDial.call(**permitted_params)
      end
    end
  end
end
