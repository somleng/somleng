module CarrierAPI
  class TTSEventFilterRequestSchema < ApplicationRequestSchema
    params do
      optional(:filter).value(:hash).hash do
        optional(:account).filled(:string)
        optional(:phone_call).filled(:string)
        optional(:from_date).value(:time)
        optional(:to_date).value(:time)
      end
    end

    rule(:filter).validate(:date_range)

    def output
      params = super.fetch(:filter, {})
      result = {}

      result[:account_id] = params.fetch(:account) if params.key?(:account)
      result[:phone_call_id] = params.fetch(:phone_call) if params.key?(:phone_call)
      date_range = DateRange.new(from_date: params[:from_date], to_date: params[:to_date])
      result[:created_at] = date_range.to_range if date_range.valid?

      result
    end
  end
end
