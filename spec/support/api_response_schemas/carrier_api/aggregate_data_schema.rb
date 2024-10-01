module APIResponseSchema
  module CarrierAPI
    AggregateDataSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "aggregate_data")

      required(:attributes).schema do
        required(:statistic).filled(:hash?)
      end
    end
  end
end
