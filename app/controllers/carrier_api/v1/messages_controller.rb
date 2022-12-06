module CarrierAPI
  module V1
    class MessagesController < CarrierAPIController
      def index
        validate_request_schema(
          with: MessageFilterRequestSchema,
          input_params: request.query_parameters,
          **serializer_options
        ) do |permitted_params|
          scope.where(permitted_params)
        end
      end

      def show
        message = scope.find(params[:id])

        respond_with_resource(message, serializer_options)
      end

      def update
        message = scope.find(params[:id])

        validate_request_schema(
          with: UpdateMessageRequestSchema,
          schema_options: { resource: message },
          **serializer_options
        ) do |permitted_params|
          message.update!(permitted_params)
          message
        end
      end

      private

      def scope
        current_carrier.messages
      end

      def serializer_options
        { serializer_class: MessageSerializer }
      end
    end
  end
end
