module CarrierAPI
  module V1
    module PhoneNumbers
      class StatsController < CarrierAPIController
        def index
          validate_request_schema(
            with: PhoneNumberStatsRequestSchema,
            input_params: request.query_parameters,
            **serializer_options
          ) do |permitted_params|
            AggregateDataQuery.new(**permitted_params).apply(scope)
          end
        end

        private

        def scope
          current_carrier.phone_numbers
        end

        def serializer_options
          {
            serializer_class: AggregateDataSerializer,
            decorator_class: nil,
            pagination_options: {
              sort_direction: :asc
            }
          }
        end
      end
    end
  end
end
