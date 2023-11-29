require "rails_helper"

module CarrierAPI
  RSpec.describe TTSEventFilterRequestSchema, type: :request_schema do
    it "normalizes the output" do
      schema = validate_request_schema(
        input_params: {
          filter: {
            from_date: Time.utc(2021, 11, 1).iso8601,
            account: "account-id",
            phone_call: "phone-call-id"
          }
        }
      )

      expect(schema.output).to include(
        account_id: "account-id",
        phone_call_id: "phone-call-id",
        created_at: Range.new(Date.new(2021, 11, 1).beginning_of_day, nil)
      )
    end

    def validate_request_schema(...)
      TTSEventFilterRequestSchema.new(...)
    end
  end
end
