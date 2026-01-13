module CarrierAPI
  class AccountRequestSchema < CarrierAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "account")
        required(:attributes).value(:hash).schema do
          required(:name).filled(:str?)
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

    def output
      result = super
      result[:access_token] = Doorkeeper::AccessToken.new
      result[:default_tts_voice] ||= TTSVoices::Voice.default
      result[:type] = :carrier_managed
      result
    end
  end
end
