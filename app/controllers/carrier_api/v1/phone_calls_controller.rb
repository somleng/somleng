module CarrierAPI
  module V1
    class PhoneCallsController < CarrierAPIController
      def index
        validate_request_schema(
          with: PhoneCallFilterRequestSchema,
          input_params: request.query_parameters,
          **serializer_options
        ) do |permitted_params|
          phone_calls_scope.where(permitted_params)
        end
      end

      def show
        phone_call = phone_calls_scope.find(params[:id])

        respond_with_resource(phone_call, serializer_options)
      end

      def update
        phone_call = phone_calls_scope.find(params[:id])

        validate_request_schema(
          with: UpdatePhoneCallRequestSchema,
          schema_options: { resource: phone_call },
          **serializer_options
        ) do |permitted_params|
          phone_call.update!(permitted_params)
          phone_call
        end
      end

      private

      def phone_calls_scope
        current_carrier.phone_calls
      end

      def serializer_options
        { serializer_class: PhoneCallSerializer }
      end
    end
  end
end
