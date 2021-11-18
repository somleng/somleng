module CarrierAPI
  class PhoneCallFilterRequestSchema < ApplicationRequestSchema
    params do
      optional(:filter).value(:hash).hash do
        optional(:account).filled(:string)
        optional(:from_date).value(:time)
        optional(:to_date).value(:time)
        optional(:direction).filled(
          :str?, included_in?: PhoneCallDecorator::TWILIO_CALL_DIRECTIONS.values
        )
      end
    end

    rule(:filter).validate(:date_range)

    def output
      filter = super.fetch(:filter, {})

      result = {}
      result[:account_id] = filter.fetch(:account) if filter.key?(:account)
      result[:direction] = PhoneCallDecorator::TWILIO_CALL_DIRECTIONS.key(filter.fetch(:direction)) if filter.key?(:direction)
      if filter.key?(:from_date)
        result[:created_at] = Range.new(
          filter[:from_date],
          filter[:to_date].change(usec: Rational(999999999, 1000))
        )
      end

      result
    end
  end
end
