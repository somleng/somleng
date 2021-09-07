module APIResponseSchema
  module Services
    PhoneCallSchema = Dry::Schema.Params do
      required(:voice_url).maybe(:str?)
      required(:voice_method).maybe(:str?)
      optional(:status_callback_url).maybe(:str?)
      optional(:status_callback_method).maybe(:str?)
      required(:twiml).maybe(:str?)
      required(:to).filled(:str?)
      required(:from).filled(:str?)
      required(:sid).filled(:str?)
      required(:account_sid).filled(:str?)
      required(:account_auth_token).filled(:str?)
      required(:direction).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
