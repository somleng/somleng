module APIResponseSchema
  module CarrierAPI
    PhoneNumberSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "phone_number")

      required(:attributes).schema do
        required(:number).filled(:str?)
        required(:voice_url).maybe(:str?)
        required(:voice_method).maybe(:str?)
        required(:status_callback_url).maybe(:str?)
        required(:status_callback_method).maybe(:str?)
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
