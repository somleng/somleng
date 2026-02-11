module CarrierAPI
  class UpdateMessageRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:string, eql?: "message")
        required(:id).filled(:string)
        required(:attributes).value(:hash).schema do
          optional(:price).filled(:decimal, lteq?: 0)
        end
      end
    end

    def output
      params = super

      result = {}
      if params.key?(:price)
        amount = InfinitePrecisionMoney.from_amount(params.fetch(:price), resource.account.billing_currency)
        result[:price_cents] = amount.cents
        result[:price_unit] = amount.currency
      end

      result
    end
  end
end
