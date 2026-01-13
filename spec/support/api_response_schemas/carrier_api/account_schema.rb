module APIResponseSchema
  module CarrierAPI
    AccountSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "account")

      required(:attributes).schema do
        required(:name).filled(:str?)
        required(:status).filled(:str?)
        required(:type).filled(:str?)
        required(:billing_enabled).filled(:bool?)
        required(:billing_mode).filled(:str?)
        optional(:auth_token).filled(:str?)
        required(:metadata).maybe(:hash?)
        required(:created_at).filled(:str?)
        required(:updated_at).filled(:str?)
      end
    end
  end
end
