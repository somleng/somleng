module APIResponseSchema
  module Services
    InboundPhoneCallSchema = Dry::Schema.Params do
      required(:voice_url).maybe(:str?)
      required(:voice_method).maybe(:str?)
      optional(:status_callback_url).maybe(:str?)
      optional(:status_callback_method).maybe(:str?)
      required(:twiml).maybe(:str?)
      required(:to).filled(:str?)
      required(:from).filled(:str?)
      required(:sid).filled(:str?)
      required(:carrier_sid).filled(:str?)
      required(:account_sid).filled(:str?)
      required(:account_auth_token).filled(:str?)
      required(:call_direction).filled(:str?, eql?: "inbound")
      required(:direction).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
      required(:default_tts_voice).filled(
        :str?,
        included_in?: TTSVoices::Voice.all.map(&:identifier)
      )
      required(:billing_parameters).maybe(:hash?) do
        schema do
          required(:enabled).filled(:bool?)
          required(:category).filled(:str?, eql?: "inbound_calls")
          required(:billing_mode).filled(:str?)
        end
      end
    end
  end
end
