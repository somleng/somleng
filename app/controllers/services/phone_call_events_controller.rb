module Services
  class PhoneCallEventsController < ServicesController
    def create
      validate_request_schema(
        with: PhoneCallEventRequestSchema,
        serializer_class: PhoneCallEventSerializer,
        location: nil
      ) do |permitted_params|
        ApplicationRecord.transaction do
          event = PhoneCallEvent.create!(permitted_params)
          UpdatePhoneCallStatus.call(
            event.phone_call,
            event_type: event.type,
            answer_epoch: event.params["answer_epoch"],
            sip_term_status: event.params["sip_term_status"]
          )

          event
        end
      end
    end
  end
end
