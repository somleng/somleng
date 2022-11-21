module Services
  class InboundMessageRequestSchema < TwilioAPIRequestSchema
    option :phone_number_validator, default: proc { PhoneNumberValidator.new }
    option :sms_gateway
    option :error_log_messages

    params do
      optional(:from).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:to).value(ApplicationRequestSchema::Types::Number, :filled?)
      required(:body).maybe(:string)
    end

    rule(:to) do |context:|
      next unless key?
      next key.failure("is invalid") unless phone_number_validator.valid?(value)

      phone_number = sms_gateway.carrier.phone_numbers.find_by(number: value)
      context[:phone_number] = phone_number

      if phone_number.blank?
        key.failure("doesn't exist")
        error_log_messages << "Phone number #{context[:to]} does not exist"
      elsif !phone_number.assigned?
        key.failure("is unassigned")
        error_log_messages << "Phone number #{context[:to]} is unassigned"
      elsif !phone_number.configured?
        key.failure("is unconfigured")
        error_log_messages << "Phone number #{context[:to]} is unconfigured"
      elsif !phone_number.enabled?
        key.failure("is disabled")
        error_log_messages << "Phone number #{context[:to]} is disabled"
      end
    end

    rule do |context:|
      error_log_messages.carrier = sms_gateway.carrier
      error_log_messages.account = context[:phone_number]&.account

      next if CarrierStanding.new(sms_gateway.carrier).good_standing?

      base.failure("carrier is not in good standing")
      error_log_messages << "Carrier is not in good standing"
    end

    def output
      params = super
      phone_number = context.fetch(:phone_number)

      {
        account: phone_number.account,
        carrier: sms_gateway.carrier,
        sms_gateway:,
        segments: 1,
        body: params.fetch(:body),
        to: params.fetch(:to),
        from: params.fetch(:from),
        status_callback_url: phone_number.status_callback_url,
        status_callback_method: phone_number.status_callback_method,
        direction: :inbound,
        status: :received
      }
    end
  end
end
