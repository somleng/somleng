module CarrierAPI
  module SchemaRules
    class InteractionFilter
      attr_reader :decorator_class, :date_range_parser

      def initialize(decorator_class:, date_range_parser: DateRangeParser.new)
        @decorator_class = decorator_class
        @date_range_parser = date_range_parser
      end

      def output(params)
        result = {}
        result[:account_id] = params.fetch(:account) if params.key?(:account)
        result[:direction] = decorator_class.direction_from(params.fetch(:direction)) if params.key?(:direction)
        result[:status] = decorator_class.status_from(params.fetch(:status)) if params.key?(:status)

        if params.key?(:from_date)
          result[:created_at] = date_range_parser.parse(
            params.fetch(:from_date), params.fetch(:to_date)
          )
        end

        result
      end
    end
  end
end
