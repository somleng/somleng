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

      required(:relationships).schema do
        required(:account).schema do
          required(:data).schema do
            required(:id).filled(:str?)
            required(:type).filled(eql?: "account")
          end
        end
      end
    end
  end
end
