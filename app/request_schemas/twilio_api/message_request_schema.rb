module TwilioAPI
  class MessageRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: proc { PhoneNumberValidator.new }
    option :phone_number_configuration_rules,
           default: -> { PhoneNumberConfigurationRules.new }
    option :sms_encoding,
           default: -> { SMSEncoding.new }
    option :smart_encoding,
           default: -> { SmartEncoding.new }
    option :sms_gateway_resolver,
           default: -> { SMSGatewayResolver.new }
    option :schema_errors,
           default: -> { SchemaErrorGenerator.new }

    params do
      optional(:From).value(ApplicationRequestSchema::Types::Number, :filled?)
      optional(:MessagingServiceSid).filled(:string)
      required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:Body).filled(:string, max_size?: 1600)
      optional(:StatusCallback).maybe(:string, format?: URL_FORMAT)
      optional(:ValidityPeriod).maybe(:integer, gteq?: 1, lteq?: 14_400)
      optional(:SmartEncoded).maybe(:bool)
      optional(:SendAt).filled(:time)
      optional(:ScheduleType).filled(:string, eql?: "fixed")
    end

    rule(:To) do |context:|
      next key.failure("is invalid") unless phone_number_validator.valid?(value)

      context[:sms_gateway], context[:channel] = sms_gateway_resolver.resolve(
        carrier: account.carrier,
        destination: value
      )

      next if context[:sms_gateway].present?

      base.failure(schema_errors.build(:unreachable_carrier))
    end

    rule(:From, :MessagingServiceSid) do |context:|
      if values[:From].blank? && values[:MessagingServiceSid].blank?
        next key(:From).failure("is required")
      end

      if values[:MessagingServiceSid].present?
        context[:messaging_service] = account.messaging_services.find_by(
          id: values.fetch(:MessagingServiceSid)
        )

        if context[:messaging_service].blank?
          next base.failure(schema_errors.build(:messaging_service_blank))
        end

        phone_numbers = context[:messaging_service].phone_numbers
        next base.failure(schema_errors.build(:messaging_service_no_senders)) if phone_numbers.empty?
        next if values[:From].blank?
      else
        phone_numbers = account.phone_numbers
      end

      context[:phone_number] = phone_numbers.find_by(number: values[:From])

      next if phone_number_configuration_rules.valid?(phone_number: context[:phone_number])

      base.failure(schema_errors.build(:message_incapable_phone_number))
    end

    rule(:SendAt) do
      if value.blank? && values[:ScheduleType].present?
        next base.failure(schema_errors.build(:sent_at_missing))
      end

      next if value.blank?
      next key(:ScheduleType).failure("is required") if values[:ScheduleType].blank?

      if values[:MessagingServiceSid].blank?
        next base.failure(schema_errors.build(:scheduled_message_messaging_service_sid_missing))
      end

      unless value.between?(900.seconds.from_now, 7.days.from_now)
        next base.failure(schema_errors.build(:send_at_invalid))
      end
    end

    def output
      params = super

      body = params.fetch(:Body)
      messaging_service = context[:messaging_service]
      status_callback_url = params.fetch(:StatusCallback) { messaging_service&.status_callback_url }
      if params.fetch(:SmartEncoded) { messaging_service&.smart_encoding? }
        body, smart_encoded = smart_encode(body)
      end
      encoding_result = sms_encoding.detect(body)

      {
        account:,
        carrier: account.carrier,
        phone_number: context[:phone_number],
        messaging_service:,
        sms_gateway: context.fetch(:sms_gateway),
        channel: context.fetch(:channel),
        body:,
        segments: encoding_result.segments,
        encoding: encoding_result.encoding,
        to: params.fetch(:To),
        from: context[:phone_number]&.number,
        status_callback_url:,
        validity_period: params[:ValidityPeriod],
        smart_encoded: smart_encoded.present?,
        send_at: params[:SendAt],
        status: message_status(context, params)
      }
    end

    private

    def smart_encode(body)
      smart_encoding_result = smart_encoding.encode(body)

      [smart_encoding_result.to_s, smart_encoding_result.smart_encoded?]
    end

    def message_status(context, params)
      return :scheduled if params[:SendAt].present?
      return :accepted if context[:messaging_service].present?

      :queued
    end
  end
end
