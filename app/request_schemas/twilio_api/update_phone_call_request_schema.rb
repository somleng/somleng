module TwilioAPI
  class UpdatePhoneCallRequestSchema < TwilioAPIRequestSchema
    class UpdatePhoneCallRules
      attr_reader :error_code

      def valid?(phone_call)
        return true if phone_call.uncompleted?

        @error_code = :invalid_call_state

        error_code.blank?
      end
    end

    option :phone_call
    option :url_validator, default: -> { URLValidator.new(allow_http: true) }
    option :twiml_validator, default: -> { TwiMLValidator.new }
    option :update_phone_call_rules, default: -> { UpdatePhoneCallRules.new }

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

    rule do
      next if update_phone_call_rules.valid?(phone_call)

      base.failure(schema_helper.build_schema_error(update_phone_call_rules.error_code))
    end

    rule(:Url) do
      next if value.blank?
      next if url_validator.valid?(value)

      key.failure("is invalid")
    end

    rule(:Twiml) do
      next if value.blank?
      next if twiml_validator.valid?(value)

      key.failure("is invalid")
    end

    rule(:StatusCallback) do
      next if value.blank?
      next if url_validator.valid?(value)

      key.failure("is invalid")
    end

    def output
      params = super

      return { status: params.fetch(:Status) } if params.key?(:Status)

      result = {}
      result[:voice_method] = params.fetch(:Method) if params.key?(:Method)
      result[:status_callback_url] = params.fetch(:StatusCallback) if params.key?(:StatusCallback)
      result[:status_callback_method] = params.fetch(:StatusCallbackMethod) if params.key?(:StatusCallbackMethod)

      if params.key?(:Url)
        result[:voice_url] = params.fetch(:Url)
        result[:twiml] = nil
      elsif params.key?(:Twiml)
        result[:twiml] = params.fetch(:Twiml)
        result[:voice_url] = nil
      end

      result
    end
  end
end
