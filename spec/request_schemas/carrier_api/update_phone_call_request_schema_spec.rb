require "rails_helper"

module CarrierAPI
  RSpec.describe UpdatePhoneCallRequestSchema, type: :request_schema do
    it "validates price and price unit" do
      carrier = create(:carrier)
      phone_call = create(:phone_call, carrier:)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_call",
              id: phone_call.id,
              attributes: {}
            }
          },
          options: {
            carrier:,
            resource: phone_call
          }
        ).success?
      ).to eq(true)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_call",
              id: phone_call.id,
              attributes: {
                price: "-0.01"
              }
            }
          },
          options: {
            carrier:,
            resource: phone_call
          }
        )
      ).to have_valid_field(:data, :attributes, :price)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_call",
              id: phone_call.id,
              attributes: {
                price: "0.01"
              }
            }
          },
          options: {
            carrier:,
            resource: phone_call
          }
        )
      ).not_to have_valid_field(:data, :attributes, :price)
    end

    it "handles post processing" do
      carrier = create(:carrier)
      account = create(:account, carrier:, billing_currency: "USD")
      phone_call = create(:phone_call, account:)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              price: "-0.01"
            }
          }
        },
        options: { carrier:, resource: phone_call }
      )

      expect(schema.output).to eq(
        price_cents: -1,
        price_unit: "USD"
      )
    end

    def validate_request_schema(...)
      UpdatePhoneCallRequestSchema.new(...)
    end
  end
end
