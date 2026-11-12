module TwilioAPI
  class MessageRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: -> { PhoneNumberValidator.new }
    option :sms_encoding,
           default: -> { SMSEncoding.new }
    option :smart_encoding,
           default: -> { SmartEncoding.new }
    option :message_destination_schema_rules,
           default: -> { MessageDestinationSchemaRules.new }
    option :sender_id, optional: true

    option :url_validator, default: proc { URLValidator.new(allow_http: true) }
    option :account_billing_policy, default: -> { AccountBillingPolicy.new }

    params do
      optional(:From).value(Types::SenderID, :filled?)
      optional(:MessagingServiceSid).filled(:string)
      required(:To).value(Types::Number, :filled?)
      required(:Body).filled(:string, max_size?: 1600)
      optional(:StatusCallback).maybe(:string)
      optional(:ValidityPeriod).maybe(:integer, gteq?: 1, lteq?: 14_400)
      optional(:SmartEncoded).maybe(:bool)
      optional(:SendAt).filled(:time)
      optional(:ScheduleType).filled(:string, eql?: "fixed")
    end

    rule(:To) do |context:|
      next key.failure("is invalid") unless phone_number_validator.valid?(value)
      next if result.errors.any?

      if message_destination_schema_rules.valid?(account:, destination: value)
        context[:sms_gateway], context[:channel] = message_destination_schema_rules.sms_gateway
      else
        base.failure(schema_helper.build_schema_error(message_destination_schema_rules.error_code))
      end
    end

    rule(:From, :MessagingServiceSid) do |context:|
      next if sender_id.present?
      next if schema_error?(:To)

      if values[:From].blank? && values[:MessagingServiceSid].blank?
        next key(:From).failure("is required")
      end

      from = context[:from] = Types::PhoneNumber.new(number: values[:From]).number
      to = Types::PhoneNumber.new(number: values[:To]).number

      if values[:MessagingServiceSid].present?
        messaging_service = account.messaging_services.find_by(
          id: values.fetch(:MessagingServiceSid)
        )

        if messaging_service.blank?
          next base.failure(schema_helper.build_schema_error(:messaging_service_blank))
        elsif !messaging_service.sender_pool.any_for?(country_code: to.country_code)
          next base.failure(schema_helper.build_schema_error(:messaging_service_no_senders))
        end

        context[:messaging_service] = messaging_service

        next if from.blank?

        if from.alphanumeric?
          context[:alphanumeric_sender_id] = messaging_service.sender_pool.alphanumeric_sender_ids_for(
            country_code: to.country_code
          ).find_by(sender_id: from.value)
        else
          context[:incoming_phone_number] = messaging_service.sender_pool.incoming_phone_numbers.find_by(number: from.value)
        end

        if context[:incoming_phone_number].blank? && context[:alphanumeric_sender_id].blank?
          base.failure(schema_helper.build_schema_error(:message_incapable_phone_number))
        end
      elsif from.alphanumeric?
        context[:alphanumeric_sender_id] = account.alphanumeric_sender_ids.approved.find_by(sender_id: from.value)

        if context[:alphanumeric_sender_id].blank?
          base.failure(schema_helper.build_schema_error(:unauthorized_alphanumeric_sender_id))
        end
      else
        context[:incoming_phone_number] = account.incoming_phone_numbers.active.find_by(number: from.value)

        if context[:incoming_phone_number].blank?
          base.failure(schema_helper.build_schema_error(:message_incapable_phone_number))
        end
      end
    end

    rule(:SendAt) do
      if value.blank? && values[:ScheduleType].present?
        next base.failure(schema_helper.build_schema_error(:sent_at_missing))
      end

      next if value.blank?
      next key(:ScheduleType).failure("is required") if values[:ScheduleType].blank?

      if values[:MessagingServiceSid].blank?
        next base.failure(schema_helper.build_schema_error(:scheduled_message_messaging_service_sid_missing))
      end

      unless value.between?(900.seconds.from_now, 7.days.from_now)
        next base.failure(schema_helper.build_schema_error(:send_at_invalid))
      end
    end

    rule(:StatusCallback) do
      next if value.blank?
      next if url_validator.valid?(value)

      key(:StatusCallback).failure("is invalid")
    end

    def output
      params = super

      body = params.fetch(:Body)
      messaging_service = context[:messaging_service]
      status_callback_url = params.fetch(:StatusCallback) { messaging_service&.status_callback_url }
      if params.fetch(:SmartEncoded) { messaging_service&.smart_encoding? }
        smart_encoding_result = smart_encoding.encode(body)
        body = smart_encoding_result.to_s
        smart_encoded = smart_encoding_result.smart_encoded?
      end
      encoding_result = sms_encoding.detect(body)

      incoming_phone_number = context[:incoming_phone_number]
      alphanumeric_sender_id = context[:alphanumeric_sender_id]
      from = context[:from]

      sms_gateway = context.fetch(:sms_gateway)
      originator_id_behavior = OriginatorIDBehavior.new(sms_gateway.sender_id_behavior)
      originator_id = originator_id_behavior.resolve(client_id: from.value, managed_id: sms_gateway.sender_id) if sender_id.blank? && from.present?
      resolved_sender_id = sender_id.present? ? sender_id : originator_id

      status = if params[:SendAt].present?
        :scheduled
      elsif resolved_sender_id.blank?
        :accepted
      else
        :queued
      end

      {
        account:,
        carrier: account.carrier,
        incoming_phone_number:,
        alphanumeric_sender_id:,
        phone_number: (incoming_phone_number.phone_number if incoming_phone_number.present?),
        messaging_service:,
        sms_gateway:,
        channel: context.fetch(:channel),
        body:,
        segments: encoding_result.segments,
        encoding: encoding_result.encoding,
        to: params.fetch(:To),
        from:,
        sender_id: resolved_sender_id,
        status_callback_url:,
        validity_period: params[:ValidityPeriod],
        smart_encoded: smart_encoded.present?,
        send_at: params[:SendAt],
        status:
      }
    end
  end
end
