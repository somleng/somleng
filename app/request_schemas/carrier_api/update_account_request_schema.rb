module CarrierAPI
  class UpdateAccountRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "account")
        required(:id).filled(:str?)
        required(:attributes).value(:hash).schema do
          optional(:name).filled(:str?)
          optional(:status).filled(:str?, included_in?: Account.status.values)
          optional(:billing_enabled).filled(:bool?)
          optional(:billing_mode).filled(:str?, included_in?: Account.billing_mode.values)
          optional(:default_tts_voice).value(
            :str?,
            included_in?: TTSVoices::Voice.all.map(&:identifier)
          )
          optional(:metadata).maybe(:hash?)
        end
      end
    end

    attribute_rule(:name) do
      if resource.customer_managed? && key?
        key.failure("Cannot be updated for customer managed accounts")
      end
    end

    attribute_rule(:default_tts_voice) do
      if resource.customer_managed? && key?
        key.failure("Cannot be updated for customer managed accounts")
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
