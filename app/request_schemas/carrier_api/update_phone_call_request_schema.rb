module CarrierAPI
  class UpdatePhoneCallRequestSchema < CarrierAPIRequestSchema
    option :update_interaction_rules,
           default: -> { SchemaRules::UpdateInteraction.new }

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:string, eql?: "phone_call")
        required(:id).filled(:string)
        required(:attributes).value(:hash).schema do
          optional(:price).filled(:decimal, lteq?: 0)
          optional(:price_unit).filled(:string)
        end
      end
    end

    attribute_rule(:price, :price_unit) do |attributes|
      update_interaction_rules.validate(attributes, context: self)
    end
  end
end
