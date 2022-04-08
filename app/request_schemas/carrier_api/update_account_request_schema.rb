module CarrierAPI
  class UpdateAccountRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "account")
        required(:id).filled(:str?)
        required(:attributes).value(:hash).schema do
          optional(:name).filled(:str?)
          optional(:status).filled(:str?, included_in?: Account.status.values)
          optional(:metadata).maybe(:hash?)
        end
      end
    end

    def output
      result = super

      if result.key?(:metadata)
        result[:metadata] = Utils.deep_merge(resource.metadata, result.fetch(:metadata))
      end

      result
    end
  end
end
