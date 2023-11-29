module CarrierAPI
  module V1
    class TTSEventsController < CarrierAPIController
      def index
        validate_request_schema(
          with: TTSEventFilterRequestSchema,
          input_params: request.query_parameters,
          **serializer_options
        ) do |permitted_params|
          tts_events_scope.where(permitted_params)
        end
      end

      def show
        respond_with_resource(tts_events_scope.find(params[:id]), serializer_options)
      end

      private

      def tts_events_scope
        current_carrier.tts_events
      end

      def serializer_options
        { serializer_class: TTSEventSerializer }
      end
    end
  end
end
