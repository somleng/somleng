module Services
  class InboundPhoneCallsController < ServicesController
    def create
      validate_request_schema(
        with: InboundPhoneCallRequestSchema,
        serializer_class: PhoneCallSerializer,
        location: nil
      ) do |permitted_params|
        ApplicationRecord.transaction do
          phone_call = PhoneCall.create!(permitted_params)
          phone_call.initiate!
          phone_call
        end
      end
    end
  end
end
