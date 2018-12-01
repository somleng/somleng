module ResponseSchema
  module API
    module Internal
      PhoneCallSchema = Dry::Validation.Schema do
        required(:account_sid).filled(:str?)
        required(:account_auth_token).filled(:str?)
        required(:voice_url).filled(:str?)
        required(:voice_method).filled(:str?)
        required(:api_version).filled(eql?: "2010-04-01")
        required(:direction).filled(:str?)
        required(:from).filled(:str?)
        required(:sid).filled(:str?)
        required(:to).filled(:str?)
        required(:routing_instructions).maybe(:hash)
      end
    end
  end
end
