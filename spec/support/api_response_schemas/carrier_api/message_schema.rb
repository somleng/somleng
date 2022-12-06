module APIResponseSchema
  module CarrierAPI
    MessageSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "message")

      required(:attributes).schema do
        required(:to).filled(:str?)
        required(:from).filled(:str?)
        required(:body).filled(:str?)
      end
    end
  end
end
