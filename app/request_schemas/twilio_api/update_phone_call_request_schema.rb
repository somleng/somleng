module TwilioAPI
  class UpdatePhoneCallRequestSchema < TwilioAPIRequestSchema
    option :phone_call
    option :url_validator, default: -> { URLValidator.new(allow_http: true) }
    option :twiml_validator, default: -> { VoiceTwiMLValidator.new }

    params do
      optional(:Status).filled(:str?, included_in?: PhoneCallStatusEvent::EVENTS.keys)
      optional(:Url).filled(:str?)
      optional(:Method).value(
        ApplicationRequestSchema::Types::UppercaseString,
        :filled?,
        included_in?: PhoneCall.voice_method.values
      )
      optional(:StatusCallback).filled(:str?)
      optional(:StatusCallbackMethod).value(
        ApplicationRequestSchema::Types::UppercaseString,
        :filled?,
        included_in?: PhoneCall.status_callback_method.values
      )
      optional(:Twiml).filled(:str?)
    end

    rule(:Url) do
      next if value.blank?
      next if url_validator.valid?(value)

      key.failure("is invalid")
    end

    rule(:StatusCallback) do
      next if value.blank?
      next if url_validator.valid?(value)

      key.failure("is invalid")
    end

    rule(:Twiml) do
      next if value.blank?
      next if twiml_validator.valid?(value)

      key.failure("is invalid")
    end

    def output
      params = super

      return { status: params.fetch(:Status) } if params.key?(:Status)

      result = {}
      result[:voice_url] = params.fetch(:Url) if params.key?(:Url)
      result[:voice_method] = params.fetch(:Method) if params.key?(:Method)
      result[:status_callback_url] = params.fetch(:StatusCallback) if params.key?(:StatusCallback)
      result[:status_callback_method] = params.fetch(:StatusCallbackMethod) if params.key?(:StatusCallbackMethod)
      result[:twiml] = params.fetch(:Twiml) if params.key?(:Twiml) && !params.key?(:Url)

      result
    end
  end
end
