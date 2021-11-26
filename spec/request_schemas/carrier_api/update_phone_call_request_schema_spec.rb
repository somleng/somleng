require "rails_helper"

module CarrierAPI
  RSpec.describe UpdatePhoneCallRequestSchema, type: :request_schema do
    it "validates price and price unit" do
      phone_call = create(:phone_call)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_call",
            id: phone_call.id,
            attributes: {}
          }
        },
        options: {
          resource: phone_call
        }
      )
      expect(schema.success?).to eq(true)

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
            resource: phone_call
          }
        )
      ).not_to have_valid_field(:data, :attributes, :price_unit)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_call",
              id: phone_call.id,
              attributes: {
                price_unit: "USD"
              }
            }
          },
          options: {
            resource: phone_call
          }
        )
      ).not_to have_valid_field(:data, :attributes, :price)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_call",
              id: phone_call.id,
              attributes: {
                price_unit: "USDT"
              }
            }
          },
          options: {
            resource: phone_call
          }
        )
      ).not_to have_valid_field(:data, :attributes, :price_unit)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_call",
              id: phone_call.id,
              attributes: {
                price: "-0.01",
                price_unit: "USD"
              }
            }
          },
          options: {
            resource: phone_call
          }
        )
      ).to have_valid_field(:data, :attributes, :price)
    end

    def validate_request_schema(options)
      UpdatePhoneCallRequestSchema.new(options)
    end
  end
end
