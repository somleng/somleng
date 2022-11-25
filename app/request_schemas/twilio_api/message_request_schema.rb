module TwilioAPI
  class MessageRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: proc { PhoneNumberValidator.new }
    option :phone_number_configuration_rules,
           default: -> { PhoneNumberConfigurationRules.new }
    option :sms_encoding,
           default: -> { SMSEncoding.new }
    option :sms_gateway_resolver,
           default: -> { SMSGatewayResolver.new }

    # parameter(
    #   "From",
    #   "A Somleng phone number in E.164 format",
    #   required: false,
    #   example: "+855716788999"
    # )
    # parameter(
    #   "Body",
    #   "The text of the message you want to send. Can be up to 1,600 characters in length.",
    #   required: true,
    #   example: "Hello World"
    # )
    # parameter(
    #   "To",
    #   "The destination phone number in E.164 format for SMS",
    #   required: true,
    #   example: "+855716788123"
    # )
    # parameter(
    #   "StatusCallback",
    #   "The URL we should call using the `status_callback_method` to send status information to your application. If specified, we POST these message status changes to the URL: `queued`, `failed`, `sent`, `delivered`, or `undelivered`. Somleng will POST its standard request parameters as well as some additional parameters including `MessageSid`, `MessageStatus`, and `ErrorCode`. URLs must contain a valid hostname (underscores are not permitted).",
    #   required: false,
    #   example: "https://example.com/status_callback"
    # )
    # parameter(
    #   "StatusCallbackMethod",
    #   "The HTTP method we should use when calling the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
    #   required: false,
    #   example: "POST"
    # )
    # parameter(
    #   "Attempt",
    #   "Total number of attempts made ( including this ) to send out the message regardless of the provider used.",
    #   required: false,
    #   example: "5"
    # )
    # parameter(
    #   "ValidityPeriod",
    #   "How long in seconds the message can remain in our outgoing message queue. After this period elapses, the message fails and we call your status callback. Can be between 1 and the default value of 14,400 seconds. After a message has been accepted by a carrier, however, we cannot guarantee that the message will not be queued after this period. We recommend that this value be at least 5 seconds.",
    #   required: false,
    #   example: "60"
    # )
    # parameter(
    #   "ScheduleType",
    #   "Indicates your intent to schedule a message. Pass the value `fixed`` to schedule a message at a fixed time.",
    #   required: false,
    #   example: "fixed"
    # )
    # parameter(
    #   "SendAt",
    #   "The time that Somleng will send the message. Must be in ISO 8601 format.",
    #   required: false,
    #   example: 30.days.from_now.iso8601
    # )

    params do
      required(:From).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:To).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:Body).filled(:string)
      optional(:StatusCallback).maybe(:string, format?: URL_FORMAT)
      optional(:StatusCallbackMethod).maybe(
        ApplicationRequestSchema::Types::UppercaseString,
        :filled?,
        included_in?: Message.status_callback_method.values
      )
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

    rule(:From) do |context:|
      context[:phone_number] = account.phone_numbers.find_by(number: value)

      next if phone_number_configuration_rules.valid?(phone_number: context[:phone_number])

      base.failure(
        text: "The 'From' phone number provided is not a valid message-capable phone number for this destination.",
        code: "21606"
      )
    end

    def output
      params = super

      body = params.fetch(:Body)
      encoding_result = sms_encoding.detect(body)

      {
        account:,
        carrier: account.carrier,
        phone_number: context.fetch(:phone_number),
        sms_gateway: context.fetch(:sms_gateway),
        channel: context.fetch(:channel),
        body:,
        segments: encoding_result.segments,
        encoding: encoding_result.encoding,
        to: params.fetch(:To),
        from: params.fetch(:From),
        status_callback_url: params[:StatusCallback],
        status_callback_method: params[:StatusCallbackMethod],
        direction: :outbound
      }
    end
  end
end
