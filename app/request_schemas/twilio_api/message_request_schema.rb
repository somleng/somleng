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

      sms_gateway, channel = sms_gateway_resolver.resolve(
        carrier: account.carrier,
        destination: value
      )

      if sms_gateway.blank?
        next base.failure(
          text: "Landline or unreachable carrier",
          code: "30006"
        )
      end

      context[:sms_gateway] = sms_gateway
      context[:channel] = channel
    end

    rule(:From, :MessagingServiceSid) do |context:|
      if values[:From].blank? && values[:MessagingServiceSid].blank?
        key(:From).failure("is required")
        next
      end

      if values[:MessagingServiceSid].present?
        messaging_service = account.messaging_services.find_by(id: values[:MessagingServiceSid])
        context[:messaging_service] = messaging_service
        next key(:MessagingServiceSid).failure("is invalid") if messaging_service.blank?
      end

      context[:phone_number] = if values[:From].blank?
                                 messaging_service.phone_numbers.order("RANDOM()").first
                               elsif messaging_service.present?
                                 messaging_service.phone_numbers.find_by(number: value)
                               else
                                 account.phone_numbers.find_by(number: values[:From])
                               end

      next if phone_number_configuration_rules.valid?(phone_number: context[:phone_number])

      base.failure(
        text: "The 'From' phone number provided is not a valid message-capable phone number for this destination.",
        code: "21606"
      )
    end

    rule(:SendAt) do
      if value.blank? && values[:ScheduleType].present?
        next base.failure(
          text: "SendAt cannot be empty for ScheduleType 'fixed'",
          code: "35111"
        )
      end

      next if value.blank?
      next key(:ScheduleType).failure("is required") if values[:ScheduleType].blank?

      if values[:MessagingServiceSid].blank?
        next base.failure(
          text: "MessagingServiceSid is required to schedule a message",
          code: "35118"
        )
      end

      unless value.between?(900.seconds.from_now, 7.days.from_now)
        next base.failure(
          text: "SendAt time must be between 900 seconds and 7 days (604800 seconds) in the future",
          code: "35114"
        )
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
        phone_number: context.fetch(:phone_number),
        messaging_service:,
        sms_gateway: context.fetch(:sms_gateway),
        channel: context.fetch(:channel),
        body:,
        segments: encoding_result.segments,
        encoding: encoding_result.encoding,
        to: params.fetch(:To),
        from: context.fetch(:phone_number).number,
        status_callback_url:,
        direction: :outbound_api,
        validity_period: params[:ValidityPeriod],
        smart_encoded: smart_encoded.present?,
        send_at: params[:SendAt],
        **status_params(context, params)
      }
    end

    private

    def smart_encode(body)
      smart_encoding_result = smart_encoding.encode(body)

      [smart_encoding_result.to_s, smart_encoding_result.smart_encoded?]
    end

    def status_params(context, params)
      status = :scheduled if params[:SendAt].present?
      status ||= :accepted if context[:messaging_service].present?
      status ||= :queued

      {
        status:,
        "#{status}_at": Time.current
      }
    end
  end
end
