module CarrierAPI
  class UpdateMessageRequestSchema < CarrierAPIRequestSchema
    option :price_parameter_parser, default: -> { PriceParameterParser.new }

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
      result[:price_cents], result[:price_unit] = price_parameter_parser.parse(params.fetch(:price), resource.account.billing_currency) if params.key?(:price)
      result
    end
  end
end
