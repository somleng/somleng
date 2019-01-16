module API
  module Internal
    class PhoneCallEventsController < BaseController
      def create
        schema_validation_result = PhoneCallEventRequestSchema.call(request.params)
        phone_call_event = CreatePhoneCallEvent.call(schema_validation_result.output)
        respond_with_phone_call_event(phone_call_event)
      end

      def show
        respond_with_phone_call_event(PhoneCallEvent.find(params[:id]))
      end

      private

      def respond_with_phone_call_event(phone_call_event)
        respond_with(
          phone_call_event,
          location: proc {
            api_internal_phone_call_phone_call_event_url(
              phone_call_event.phone_call, phone_call_event
            )
          },
          serializer_class: PhoneCallEventSerializer
        )
      end
    end
  end
end
