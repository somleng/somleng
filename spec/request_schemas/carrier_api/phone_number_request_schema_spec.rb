require "rails_helper"

module CarrierAPI
  RSpec.describe PhoneNumberRequestSchema, type: :request_schema do
    it "validates number" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, number: "1234", carrier:)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              number: "1294"
            }
          }
        },
        options: { carrier: }
      )
      expect(schema.success?).to eq(true)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {}
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :number)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: ""
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :number)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "1234"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :number)

      schema = validate_request_schema(
        input_params: {
          data: {
            id: phone_number.id,
            type: "phone_number",
            attributes: {
              number: "1294"
            }
          }
        },
        options: { carrier:, resource: phone_number }
      )
      expect(schema.success?).to eq(true)

      schema = validate_request_schema(
        input_params: {
          data: {
            id: phone_number.id,
            type: "phone_number",
            attributes: {}
          }
        },
        options: { carrier:, resource: phone_number }
      )
      expect(schema.success?).to eq(true)

      schema = validate_request_schema(
        input_params: {
          data: {
            id: phone_number.id,
            type: "phone_number",
            attributes: {
              number: "1234"
            }
          }
        },
        options: { carrier:, resource: phone_number }
      )
      expect(schema.success?).to eq(true)

      create(:phone_number, number: "6789", carrier:)
      expect(
        validate_request_schema(
          input_params: {
            data: {
              id: phone_number.id,
              type: "phone_number",
              attributes: {
                number: "6789"
              }
            }
          },
          options: { carrier:, resource: phone_number }
        )
      ).not_to have_valid_field(:data, :attributes, :number)
    end

    it "validates account" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      other_account = create(:account)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              number: "1294"
            }
          }
        },
        options: { carrier: }
      )
      expect(schema.success?).to eq(true)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              number: "1294"
            },
            relationships: {
              account: {
                data: {
                  type: "account",
                  id: account.id
                }
              }
            }
          }
        },
        options: { carrier: }
      )
      expect(schema.success?).to eq(true)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "1234"
              },
              relationships: {
                account: {
                  data: {
                    type: "account",
                    id: other_account.id
                  }
                }
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :relationships, :account)
    end

    it "normalizes the output" do
      carrier = create(:carrier)
      account = create(:account, carrier:)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              number: "1294",
              voice_url: "https://example.com/twiml"
            },
            relationships: {
              account: {
                data: {
                  type: "account",
                  id: account.id
                }
              }
            }
          }
        },
        options: { carrier: }
      )

      expect(schema.output).to include(
        account:,
        number: "1294",
        voice_url: "https://example.com/twiml",
        voice_method: "POST"
      )
    end

    def validate_request_schema(...)
      PhoneNumberRequestSchema.new(...)
    end
  end
end
