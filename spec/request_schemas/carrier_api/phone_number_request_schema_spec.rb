require "rails_helper"

module CarrierAPI
  RSpec.describe PhoneNumberRequestSchema, type: :request_schema do
    it "validates number" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, number: "1234", carrier:)

      expect(
        validate_request_schema(
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
      ).to have_valid_field(:data, :attributes, :number)

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

      expect(
        validate_request_schema(
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
      ).to have_valid_field(:data, :attributes, :number)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              id: phone_number.id,
              type: "phone_number"
            }
          },
          options: { carrier:, resource: phone_number }
        )
      ).to have_valid_field(:data, :attributes, :number)

      expect(
        validate_request_schema(
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
      ).not_to have_valid_field(:data, :attributes, :number)
    end

    it "validates account" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      same_carrier_account = create(:account, carrier:)
      phone_number_with_account = create(:phone_number, account:)
      other_carrier_account = create(:account)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number"
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :relationships, :account)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
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
      ).to have_valid_field(:data, :relationships, :account)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              relationships: {
                account: {
                  data: {
                    type: "account",
                    id: other_carrier_account.id
                  }
                }
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :relationships, :account)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              id: phone_number_with_account.id,
              type: "phone_number",
              relationships: {
                account: {
                  data: {
                    type: "account",
                    id: same_carrier_account.id
                  }
                }
              }
            }
          },
          options: { carrier:, resource: phone_number_with_account }
        )
      ).not_to have_valid_field(:data, :relationships, :account)

      phone_number_without_account = create(:phone_number, carrier:)
      expect(
        validate_request_schema(
          input_params: {
            data: {
              id: phone_number_without_account.id,
              type: "phone_number",
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
          options: { carrier:, resource: phone_number_without_account }
        )
      ).to have_valid_field(:data, :relationships, :account)
    end

    it "normalizes the output" do
      carrier = create(:carrier)
      account = create(:account, carrier:)

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

      expect(schema.output).to include(
        account:,
        number: "1294"
      )
    end

    def validate_request_schema(...)
      PhoneNumberRequestSchema.new(...)
    end
  end
end
