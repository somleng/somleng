module CarrierAPI
  module V1
    class EventsController < CarrierAPIController
      def index
        respond_with_resource(events_scope, serializer_options)
      end

      def show
        respond_with_resource(events_scope.find(params[:id]), serializer_options)
      end

      private

      def events_scope
        current_carrier.events
      end

      def serializer_options
        { serializer_class: EventSerializer }
      end
    end
  end
end
