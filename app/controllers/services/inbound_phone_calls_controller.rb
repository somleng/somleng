module Services
  class InboundPhoneCallsController < ServicesController
    def create
      validate_request_schema(
        with: InboundPhoneCallRequestSchema,
        serializer_class: PhoneCallSerializer,
        location: nil,
        schema_options: { error_log_messages: },
        on_error: ->(schema) { handle_errors(schema) }
      ) do |permitted_params|
        ApplicationRecord.transaction do
          phone_call = PhoneCall.create!(permitted_params)
          phone_call.initiate!
          phone_call
        end
      end
    end

    def handle_errors(_schema)
      return if error_log_messages.empty?

      ErrorLog.create!(
        carrier: error_log_messages.carrier,
        account: error_log_messages.account,
        error_message: error_log_messages.messages.to_sentence
      )
    end

    def error_log_messages
      @error_log_messages ||= ErrorLogMessages.new
    end
  end
end
