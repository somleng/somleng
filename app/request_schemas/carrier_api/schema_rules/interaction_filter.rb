module CarrierAPI
  module SchemaRules
    class InteractionFilter
      attr_reader :decorator_class

      def initialize(decorator_class:)
        @decorator_class = decorator_class
      end

      def output(params)
        result = {}
        result[:account_id] = params.fetch(:account) if params.key?(:account)
        if params.key?(:direction)
          result[:direction] = decorator_class.direction_from(params.fetch(:direction))
        end
        result[:status] = decorator_class.status_from(params.fetch(:status)) if params.key?(:status)

        date_range = DateRange.new(from_date: params[:from_date], to_date: params[:to_date])
        result[:created_at] = date_range.to_range if date_range.valid?

        result
      end
    end
  end
end
