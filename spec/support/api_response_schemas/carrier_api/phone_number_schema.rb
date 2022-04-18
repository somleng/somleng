module APIResponseSchema
  module CarrierAPI
    PhoneNumberSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "phone_number")

      required(:attributes).schema do
        required(:number).filled(:str?)
        required(:enabled).filled(:bool?)
        required(:created_at).filled(:str?)
        required(:updated_at).filled(:str?)
      end

      required(:relationships).schema do
        optional(:account).schema do
          required(:data).schema do
            required(:id).filled(:str?)
            required(:type).filled(eql?: "account")
          end
        end
      end
    end
  end
end
