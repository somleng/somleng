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

    it "validates type" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, carrier:, number: "12513095542", type: :local)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "1294",
                type: "short_code"
              }
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :attributes, :type)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                type: "mobile"
              }
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :attributes, :type)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                type: "mobile"
              }
            }
          },
          options: { carrier:, resource: phone_number }
        )
      ).to have_valid_field(:data, :attributes, :type)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "+12513095542",
                type: "short_code"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :type)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "1294",
                type: "local"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :type)
    end

    it "validates country" do
      carrier = create(:carrier)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "1294",
                country: "KH"
              }
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :attributes, :country)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "+855715100987",
                country: "US"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :country)
    end

    it "validates the price and currency" do
      carrier = create(:carrier, billing_currency: "USD")

      valid_schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              price: "1.15",
              currency: "USD"
            }
          }
        },
        options: { carrier: }
      )

      expect(valid_schema).to have_valid_field(:data, :attributes, :price)
      expect(valid_schema).to have_valid_field(:data, :attributes, :currency)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                price: "-0.01"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :price)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                price: "0.01"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :currency)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                currency: carrier.billing_currency.iso_code
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :price)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                price: "1.15",
                currency: "CAD"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :currency)
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

    it "handles output for new records" do
      carrier = create(:carrier, billing_currency: "KHR")
      account = create(:account, carrier:)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              number: "+855715100987",
              type: "mobile"
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

      expect(schema.output).to eq(
        carrier:,
        account:,
        number: "855715100987",
        type: "mobile",
        iso_country_code: "KH"
      )
    end

    it "handles output for existing records" do
      carrier = create(:carrier, billing_currency: "CAD")
      account = create(:account, carrier:)
      phone_number = create(
        :phone_number,
        number: "12366130851",
        carrier:,
        account:,
        iso_country_code: "US",
        price: Money.new(0, "CAD")
      )

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              enabled: false,
              country: "CA",
              type: "mobile",
              price: "1.15",
              currency: "CAD"
            }
          }
        },
        options: { carrier:, resource: phone_number }
      )

      expect(schema.output).to include(
        enabled: false,
        iso_country_code: "CA",
        type: "mobile",
        price: Money.from_amount(1.15, "CAD")
      )
    end

    def validate_request_schema(...)
      PhoneNumberRequestSchema.new(...)
    end
  end
end
