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
      result[:price] = params.fetch(:price) if params.key?(:price)
      result[:price_unit] = resource.account.billing_currency
      result
    end
  end
end
