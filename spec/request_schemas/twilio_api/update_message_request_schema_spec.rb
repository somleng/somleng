require "rails_helper"

module TwilioAPI
  RSpec.describe UpdateMessageRequestSchema, type: :request_schema do
    it "validates Body" do
      queued_message = create(:message, :queued)

      expect(
        validate_request_schema(
          input_params: {
            Body: ""
          }
        )
      ).to have_valid_field(:Body)

      expect(
        validate_request_schema(
          input_params: {
            Body: "Foobar"
          }
        )
      ).not_to have_valid_field(:Body)

      expect(
        validate_request_schema(
          input_params: {
            Body: ""
          },
          options: {
            message: queued_message,
            account: queued_message.account
          }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:update_before_complete).message)
    end

    it "validates Status" do
      queued_message = create(:message, :queued)

      expect(
        validate_request_schema(
          input_params: {
            Status: "canceled"
          }
        )
      ).to have_valid_field(:Status)

      expect(
        validate_request_schema(
          input_params: {
            Status: "invalid"
          }
        )
      ).not_to have_valid_field(:Status)

      expect(
        validate_request_schema(
          input_params: {
            Status: "canceled"
          },
          options: {
            message: queued_message,
            account: queued_message.account
          }
        )
      ).not_to have_valid_schema(error_message: ApplicationError::Errors.fetch(:message_not_cancelable).message)
    end

    it "handles post processing for redacting a message" do
      message = create(:message)

      schema = validate_request_schema(
        input_params: { Body: "" },
        options: { message:, account: message.account }
      )

      expect(schema.output).to eq(redact: true)
    end

    it "handles post processing for canceling a message" do
      message = create(:message)

      schema = validate_request_schema(
        input_params: { Status: "canceled" },
        options: { message:, account: message.account }
      )

      expect(schema.output).to eq(cancel: true)
    end

    def validate_request_schema(input_params:, options: {})
      options[:account] ||= build_stubbed(:account)
      options[:message] ||= build_stubbed(:message, account: options[:account])

      UpdateMessageRequestSchema.new(input_params:, options:)
    end
  end
end
