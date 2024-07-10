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
      required(:account_sid).filled(:str?)
      required(:account_auth_token).filled(:str?)
      required(:default_tts_voice).filled(
        :str?,
        included_in?: TTSVoices::Voice.all.map(&:identifier)
      )
      required(:direction).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
