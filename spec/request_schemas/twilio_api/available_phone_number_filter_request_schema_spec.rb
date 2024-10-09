require "rails_helper"

module TwilioAPI
  RSpec.describe AvailablePhoneNumberFilterRequestSchema, type: :request_schema do
    it "validates InRateCenter and InLata" do
      expect(
        validate_request_schema(
          input_params: {
            InLata: "888",
            InRateCenter: "NEWTORONTO"
          }
        )
      ).to have_valid_field(:InRateCenter)

      expect(
        validate_request_schema(
          input_params: {
            InLata: "888"
          }
        )
      ).to have_valid_field(:InLata)

      expect(
        validate_request_schema(
          input_params: {
            InRateCenter: "NEWTORONTO"
          }
        )
      ).not_to have_valid_field(:InRateCenter)
    end

    it "handles post processing" do
      schema = validate_request_schema(
        input_params: {
          type: "Local",
          country_code: "CA",
          AreaCode: "201",
          InRegion: "ON",
          InLocality: "Toronto",
          InLata: "888",
          InRateCenter: "NEWTORONTO"
        }
      )

      expect(schema.output).to eq(
        type: "local",
        iso_country_code: "CA",
        area_code: "201",
        iso_region_code: "ON",
        locality: "Toronto",
        lata: "888",
        rate_center: "NEWTORONTO"
      )
    end

    def validate_request_schema(input_params:, options: {})
      options[:account] ||= build_stubbed(:account)

      AvailablePhoneNumberFilterRequestSchema.new(input_params:, options:)
    end
  end
end
