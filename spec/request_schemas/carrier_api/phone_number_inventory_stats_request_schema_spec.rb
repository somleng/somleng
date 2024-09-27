require "rails_helper"

module CarrierAPI
  RSpec.describe PhoneNumberInventoryStatsRequestSchema, type: :request_schema do
    it "validates the filter type" do
      expect(
        validate_request_schema(
          input_params: {}
        )
      ).not_to have_valid_field(:filter)

      expect(
        validate_request_schema(
          input_params: {
            filter: {
              type: "local"
            }
          }
        )
      ).to have_valid_field(:filter, :type)

      expect(
        validate_request_schema(
          input_params: {
            filter: {
              type: "mobile"
            }
          }
        )
      ).not_to have_valid_field(:filter, :type)
    end

    it "validates the filter available" do
      expect(
        validate_request_schema(
          input_params: {
            filter: {
              available: "true"
            }
          }
        )
      ).to have_valid_field(:filter, :available)

      expect(
        validate_request_schema(
          input_params: {
            filter: {
              available: "false"
            }
          }
        )
      ).not_to have_valid_field(:filter, :available)
    end

    it "validates the group_by array" do
      expect(
        validate_request_schema(
          input_params: {}
        )
      ).not_to have_valid_field(:group_by)

      expect(
        validate_request_schema(
          input_params: {
            group_by: [ "country", "region", "locality" ]
          }
        )
      ).to have_valid_field(:filter, :group_by)

      expect(
        validate_request_schema(
          input_params: {
            group_by: "currency"
          }
        )
      ).not_to have_valid_field(:group_by)
    end

    it "validates the having clause" do
      expect(
        validate_request_schema(
          input_params: {}
        )
      ).to have_valid_field(:having)

      expect(
        validate_request_schema(
          input_params: {
            having: {
              count: {
                lteq: "5"
              }
            }
          }
        )
      ).to have_valid_field(:having)

      expect(
        validate_request_schema(
          input_params: {
            having: {
              count: {
                foo: 1
              }
            }
          }
        )
      ).not_to have_valid_field(:having)
    end

    def validate_request_schema(...)
      PhoneNumberInventoryStatsRequestSchema.new(...)
    end
  end
end
