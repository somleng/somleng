module Services
  class AudioStreamRequestSchema < ServicesRequestSchema
    params do
      required(:phone_call_id).filled(:str?)
      required(:url).filled(:str?)
      optional(:custom_parameters).maybe(:hash)
    end

    rule(:phone_call_id) do |context:|
      context[:phone_call] = PhoneCall.find_by(id: value)

      key.failure("does not exist") if context[:phone_call].blank?
    end

    def output
      params = super

      {
        phone_call: context.fetch(:phone_call),
        account: context.fetch(:phone_call).account,
        url: params.fetch(:url),
        custom_parameters: params.fetch(:custom_parameters, {})
      }
    end
  end
end
