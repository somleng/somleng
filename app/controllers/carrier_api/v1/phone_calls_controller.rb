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
        respond_with_resource(phone_calls_scope.find(params[:id]), serializer_options)
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
