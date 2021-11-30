module APIResponseSchema
  module CarrierAPI
    EventSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "event")

      required(:attributes).schema do
        required(:type).filled(:str?)
        required(:details).schema do
          required(:data).filled(:hash)
        end
        required(:created_at).filled(:str?)
        required(:updated_at).filled(:str?)
      end
    end
  end
end
