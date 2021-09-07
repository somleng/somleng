module Services
  class InboundPhoneCallsController < ServicesController
    def create
      validate_request_schema(
        with: InboundPhoneCallRequestSchema,
        serializer_class: PhoneCallSerializer,
        location: nil
      ) do |permitted_params|
        ApplicationRecord.transaction do
          phone_call = PhoneCall.create!(permitted_params)
          phone_call.initiate!
          phone_call
        end
      end
    end

    private

    def handle_failure(schema, _options)
      output = schema.output

      return unless output.key?(:inbound_sip_trunk)

      Log.create!(
        status: :failure,
        error_message: "Failed to create inbound phone call",
        type: :inbound_phone_call_failure,
        body: schema.errors(full: true).to_h.values.flatten.to_sentence,
        carrier: output.fetch(:inbound_sip_trunk).carrier,
        phone_number: output[:phone_number],
        account: output[:phone_number]&.account
      )
    end
  end
end
