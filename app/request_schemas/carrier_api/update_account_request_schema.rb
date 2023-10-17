module CarrierAPI
  class UpdateAccountRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "account")
        required(:id).filled(:str?)
        required(:attributes).value(:hash).schema do
          optional(:name).filled(:str?)
          optional(:status).filled(:str?, included_in?: Account.status.values)
          optional(:default_tts_provider).value(:str?, included_in?: Account.default_tts_provider.values)
          optional(:metadata).maybe(:hash?)
        end
      end
    end

    def output
      result = super

      if result.key?(:metadata)
        new_metadata = result.fetch(:metadata).stringify_keys
        result[:metadata] = resource.metadata.deep_merge(new_metadata)
      end

      result
    end
  end
end
