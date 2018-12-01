module API
  module Internal
    class PhoneCallsController < BaseController
      def create
        schema_validation_result = PhoneCallRequestSchema.call(request.params)
        if schema_validation_result.success?
          phone_call = InitiateInboundCall.call(schema_validation_result.output)
          respond_with_phone_call(phone_call)
        else
          respond_with(schema_validation_result)
        end
      end

      def show
        respond_with_phone_call(PhoneCall.find(params[:id]))
      end

      private

      def respond_with_phone_call(phone_call)
        respond_with(
          phone_call,
          location: proc { api_internal_phone_call_url(phone_call) },
          serializer_class: PhoneCallSerializer
        )
      end
    end
  end
end
