require "rails_helper"

module Services
  RSpec.describe InboundMessageRequestSchema, type: :request_schema do
    it "validates carrier is in good standing" do
      carrier = create_restricted_carrier
      sms_gateway = create(:sms_gateway, carrier:)

      expect(
        validate_request_schema(
          options: { sms_gateway: }
        )
      ).not_to have_valid_schema(
        error_message: ApplicationError::Errors.fetch(:carrier_standing).message
      )
    end

    it "normalizes the output" do
      carrier = create(:carrier)
      account = create(:account)
      sms_gateway = create(:sms_gateway, carrier:)
      messaging_service = create(
        :messaging_service,
        :defer_to_sender,
        carrier:,
        account:
      )
      phone_number = create(:phone_number, account:, carrier:, number: "855715222222")
      create(
        :phone_number_configuration,
        phone_number:,
        messaging_service:,
        sms_url: "https://www.example.com/message.xml",
        sms_method: "GET"
      )

      schema = validate_request_schema(
        input_params: {
          to: "855715222222",
          from: "855716100230",
          body: "Hello world"
        },
        options: {
          sms_gateway:
        }
      )

      expect(schema.output).to include(
        account:,
        to: "855715222222",
        from: "855716100230",
        phone_number:,
        messaging_service:,
        sms_url: "https://www.example.com/message.xml",
        sms_method: "GET",
        body: "Hello world"
      )
    end

    def validate_request_schema(input_params: {}, options: {})
      options.reverse_merge!(
        error_log_messages: ErrorLogMessages.new,
        sms_gateway: build_stubbed(:sms_gateway)
      )
      InboundMessageRequestSchema.new(input_params:, options:)
    end
  end
end
