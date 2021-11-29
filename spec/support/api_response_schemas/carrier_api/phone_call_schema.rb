module APIResponseSchema
  module CarrierAPI
    PhoneCallSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "phone_call")

      required(:attributes).schema do
        required(:to).filled(:str?)
        required(:from).filled(:str?)
      end
    end
  end
end
