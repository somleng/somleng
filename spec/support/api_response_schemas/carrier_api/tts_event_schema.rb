module APIResponseSchema
  module CarrierAPI
    TTSEventSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "tts_event")

      required(:attributes).schema do
        required(:voice).filled(:str?)
        required(:characters).filled(:int?)
        required(:created_at).filled(:str?)
        required(:updated_at).filled(:str?)
      end

      required(:relationships).schema do
        required(:account).schema do
          required(:data).schema do
            required(:id).filled(:str?)
            required(:type).filled(eql?: "account")
          end
        end

        required(:phone_call).schema do
          required(:data).schema do
            required(:id).filled(:str?)
            required(:type).filled(eql?: "phone_call")
          end
        end
      end
    end
  end
end
