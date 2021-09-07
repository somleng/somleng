module CarrierAPI
  class AccountRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "account")
        required(:attributes).value(:hash).schema do
          required(:name).filled(:str?)
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
