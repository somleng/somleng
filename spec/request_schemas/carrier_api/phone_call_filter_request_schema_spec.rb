require "rails_helper"

module CarrierAPI
  RSpec.describe PhoneCallFilterRequestSchema, type: :request_schema do
    it "validates the from_date and to_date" do
      expect(
        validate_request_schema(
          input_params: {
            filter: {
              from_date: Time.utc(2021, 11, 1).iso8601,
              to_date: Time.utc(2021, 11, 30, 1, 1).iso8601
            }
          }
        )
      ).to have_valid_field(:filter, :from_date)

      expect(
        validate_request_schema(
          input_params: {
            filter: {
              from_date: Time.utc(2021, 11, 1).iso8601
            }
          }
        )
      ).to have_valid_field(:filter, :date_range)

      expect(
        validate_request_schema(
          input_params: {
            filter: {
              from_date: Time.utc(2021, 11, 1).iso8601,
              to_date: Time.utc(2021, 10, 31).iso8601
            }
          }
        )
      ).not_to have_valid_field(:filter, :date_range)
    end

    it "validates direction" do
      expect(
        validate_request_schema(
          input_params: {
            filter: {
              direction: "outbound-api"
            }
          }
        )
      ).to have_valid_field(:filter, :direction)

      expect(
        validate_request_schema(
          input_params: {
            filter: {
              direction: "invalid"
            }
          }
        )
      ).not_to have_valid_field(:filter, :direction)
    end

    it "validates status" do
      expect(
        validate_request_schema(
          input_params: {
            filter: {
              status: "queued"
            }
          }
        )
      ).to have_valid_field(:filter, :status)

      expect(
        validate_request_schema(
          input_params: {
            filter: {
              status: "invalid"
            }
          }
        )
      ).not_to have_valid_field(:filter, :status)
    end

    it "normalizes the output" do
      schema = validate_request_schema(
        input_params: {
          filter: {
            from_date: Time.utc(2021, 11, 1).iso8601,
            to_date: Time.utc(2021, 11, 30).iso8601,
            account: "account-id",
            direction: "outbound-api",
            status: "queued"
          }
        }
      )

      expect(schema.output).to include(
        account_id: "account-id",
        direction: [ "outbound_api" ],
        status: match_array(%w[queued initiating initiated])
      )
    end

    def validate_request_schema(...)
      PhoneCallFilterRequestSchema.new(...)
    end
  end
end
