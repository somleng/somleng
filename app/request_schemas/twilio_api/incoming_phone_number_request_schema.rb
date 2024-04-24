module TwilioAPI
  class IncomingPhoneNumberRequestSchema < TwilioAPIRequestSchema
    option :phone_number, optional: true
    option :url_validator, default: -> { URLValidator.new(allow_http: true) }

    params do
      optional(:PhoneNumber).maybe(ApplicationRequestSchema::Types::Number, :filled?)
      optional(:VoiceUrl).filled(:str?)
      optional(:VoiceMethod).filled(
        ApplicationRequestSchema::Types::UppercaseString,
        included_in?: PhoneNumberConfiguration.voice_method.values
      )
      optional(:SmsUrl).filled(:str?)
      optional(:SmsMethod).filled(
        ApplicationRequestSchema::Types::UppercaseString,
        included_in?: PhoneNumberConfiguration.sms_method.values
      )
      optional(:StatusCallback).filled(:str?)
      optional(:StatusCallbackMethod).filled(
        ApplicationRequestSchema::Types::UppercaseString,
        included_in?: PhoneNumberConfiguration.status_callback_method.values
      )
    end

    rule(:PhoneNumber) do |context:|
      if phone_number.present?
        context[:phone_number] = phone_number
        next
      end

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

      result = {
        account:,
        phone_number: context.fetch(:phone_number)
      }

      configuration = {}
      configuration[:voice_url] = params.fetch(:VoiceUrl) if params.key?(:VoiceUrl)
      configuration[:voice_method] = params.fetch(:VoiceMethod) if params.key?(:VoiceMethod)
      configuration[:sms_url] = params.fetch(:SmsUrl) if params.key?(:SmsUrl)
      configuration[:sms_method] = params.fetch(:SmsMethod) if params.key?(:SmsMethod)
      configuration[:status_callback_url] = params.fetch(:StatusCallback) if params.key?(:StatusCallback)
      configuration[:status_callback_method] = params.fetch(:StatusCallbackMethod) if params.key?(:StatusCallbackMethod)

      result[:configuration] = configuration if configuration.any?

      result
    end
  end
end
