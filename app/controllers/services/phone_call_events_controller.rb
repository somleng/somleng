module Services
  class PhoneCallEventsController < ServicesController
    def create
      validate_request_schema(
        with: PhoneCallEventRequestSchema,
        serializer_class: PhoneCallEventSerializer,
        location: nil
      ) do |permitted_params|
        HandlePhoneCallEvent.call(permitted_params)
      end
    end
  end
end
