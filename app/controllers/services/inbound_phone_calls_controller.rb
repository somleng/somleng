module Services
  class InboundPhoneCallsController < ServicesController
    def create
      schema = initialize_schema(with: InboundPhoneCallRequestSchema)

      if schema.success?
        ApplicationRecord.transaction do
          phone_call = PhoneCall.create!(schema.output)
          phone_call.initiate!
          respond_with_resource(phone_call, serializer_class: PhoneCallSerializer, location: nil)
        end
      else
        log = create_log(
          schema,
          status: :failure,
          error_message: "Failed to create inbound phone call",
          type: :inbound_phone_call_failure,
          body: schema.errors(full: true).to_h.values.flatten.to_sentence
        )
        respond_with_error(schema, log: log)
      end
    end

    private

    def create_log(schema, options = {})
      output = schema.output

      return unless output.key?(:inbound_sip_trunk)

      Log.create!(
        options.reverse_merge(
          carrier: output.fetch(:inbound_sip_trunk).carrier,
          phone_number: output[:phone_number],
          account: output[:phone_number]&.account
        )
      )
    end
  end
end
