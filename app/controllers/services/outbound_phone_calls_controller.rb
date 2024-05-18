module Services
  class OutboundPhoneCallsController < ServicesController
    def create
      validate_request_schema(
        with: OutboundPhoneCallsRequestSchema,
        serializer_class: OutboundPhoneCallSerializer,
        location: nil,
        schema_options: { error_log_messages: },
        on_error: ->(schema) { handle_errors(schema) }
      ) do |permitted_params|
        CreatePhoneCallsFromOutboundDial.call(permitted_params)
      end
    end

    private

    def handle_errors(_schema)
      return if error_log_messages.empty?

      CreateErrorLog.call(
        type: :inbound_call,
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
