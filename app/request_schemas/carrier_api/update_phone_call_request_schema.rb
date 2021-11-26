module CarrierAPI
  class UpdatePhoneCallRequestSchema < JSONAPIRequestSchema
    CURRENCIES = Money::Currency.table.values.pluck(:iso_code)

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:string, eql?: "phone_call")
        required(:id).filled(:string)
        required(:attributes).value(:hash).schema do
          optional(:price).filled(:decimal)
          optional(:price_unit).filled(:string)
        end
      end
    end

    attribute_rule(:price, :price_unit) do |attributes|
      if attributes.values_at(:price, :price_unit).one?
        key(attribute_key_path(:price)).failure(text: "is blank") unless attributes.key?(:price)
        key(attribute_key_path(:price_unit)).failure(text: "is blank") unless attributes.key?(:price_unit)
      end
    end

    attribute_rule(:price_unit) do
      next unless key?

      key.failure("must be one of ISO 4217 currency format") unless CURRENCIES.include?(value)
    end
  end
end
