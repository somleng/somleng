module Services
  class InboundPhoneCallsController < ServicesController
    def create
      validate_request_schema(
        with: InboundPhoneCallRequestSchema,
        serializer_class: PhoneCallSerializer,
        location: nil,
        schema_options: { default_context: { error_log_messages: [] }},
        on_error: ->(schema) { handle_errors(schema) }
      ) do |permitted_params|
        ApplicationRecord.transaction do
          phone_call = PhoneCall.create!(permitted_params)
          phone_call.initiate!
          phone_call
        end
      end
    end

    def handle_errors(schema)
      return if schema.context.fetch(:error_log_messages).empty?

      ErrorLog.create!(
        carrier: schema.context[:carrier],
        account: schema.context[:account],
        error_message: schema.context.fetch(:error_log_messages).to_sentence
      )
    end
  end
end
