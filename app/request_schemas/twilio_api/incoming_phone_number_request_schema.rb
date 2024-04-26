module TwilioAPI
  class IncomingPhoneNumberRequestSchema < TwilioAPIRequestSchema
    option :incoming_phone_number, optional: true
    option :url_validator, default: -> { URLValidator.new(allow_http: true) }

    params do
      optional(:PhoneNumber).maybe(ApplicationRequestSchema::Types::Number, :filled?)
      optional(:FriendlyName).filled(:str?, max_size?: 64)
      optional(:VoiceUrl).filled(:str?)
      optional(:VoiceMethod).filled(
        ApplicationRequestSchema::Types::UppercaseString,
        included_in?: IncomingPhoneNumber.voice_method.values
      )
      optional(:SmsUrl).filled(:str?)
      optional(:SmsMethod).filled(
        ApplicationRequestSchema::Types::UppercaseString,
        included_in?: IncomingPhoneNumber.sms_method.values
      )
      optional(:StatusCallback).filled(:str?)
      optional(:StatusCallbackMethod).filled(
        ApplicationRequestSchema::Types::UppercaseString,
        included_in?: IncomingPhoneNumber.status_callback_method.values
      )
    end

    rule(:PhoneNumber) do |context:|
      next if incoming_phone_number.present?

      context[:phone_number] = account.available_phone_numbers.find_by(number: value)
      key.failure("does not exist") if context[:phone_number].blank?
    end

    rule(:VoiceUrl) do
      next unless key?
      next if url_validator.valid?(value)

      key.failure("is invalid")
    end

    rule(:SmsUrl) do
      next unless key?
      next if url_validator.valid?(value)

      key.failure("is invalid")
    end

    rule(:StatusCallback) do
      next unless key?
      next if url_validator.valid?(value)

      key.failure("is invalid")
    end

    def output
      params = super

      result = {}
      result[:account] = account
      result[:phone_number] = context.fetch(:phone_number) if context.key?(:phone_number)
      result[:friendly_name] = params.fetch(:FriendlyName) if params.key?(:FriendlyName)
      result[:voice_url] = params.fetch(:VoiceUrl) if params.key?(:VoiceUrl)
      result[:voice_method] = params.fetch(:VoiceMethod) if params.key?(:VoiceMethod)
      result[:sms_url] = params.fetch(:SmsUrl) if params.key?(:SmsUrl)
      result[:sms_method] = params.fetch(:SmsMethod) if params.key?(:SmsMethod)
      result[:status_callback_url] = params.fetch(:StatusCallback) if params.key?(:StatusCallback)
      result[:status_callback_method] = params.fetch(:StatusCallbackMethod) if params.key?(:StatusCallbackMethod)
      result
    end
  end
end
