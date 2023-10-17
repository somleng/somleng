module CarrierAPI
  class AccountRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "account")
        required(:attributes).value(:hash).schema do
          required(:name).filled(:str?)
          optional(:default_tts_provider).value(:str?, included_in?: Account.default_tts_provider.values)
          optional(:metadata).maybe(:hash?)
        end
      end
    end

    def output
      result = super
      result[:access_token] = Doorkeeper::AccessToken.new
      result
    end
  end
end
