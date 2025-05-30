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

    it "validates visibility" do
      carrier = create(:carrier)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                visibility: "public"
              }
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :attributes, :visibility)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                visibility: "invalid"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :visibility)
    end

    it "validates country" do
      carrier = create(:carrier)

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

    it "validates region" do
      carrier = create(:carrier)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "12513095542",
                region: "ON",
                country: "CA"
              }
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :attributes, :region)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "12513095542",
                region: "AK",
                country: "CA"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :region)
    end

    it "validates lata" do
      carrier = create(:carrier)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "12513095542",
                region: "CA",
                country: "US",
                lata: "730"
              }
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :attributes, :lata)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                number: "12513095542",
                region: "CA",
                country: "US",
                lata: "001"
              }
            }
          },
          options: { carrier: }
        )
      ).not_to have_valid_field(:data, :attributes, :lata)
    end

    it "validates price" do
      carrier = create(:carrier)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                price: "1.15"
              }
            }
          },
          options: { carrier: }
        )
      ).to have_valid_field(:data, :attributes, :price)

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
    end

    it "validates metadata" do
      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                metadata: {}
              }
            }
          }
        )
      ).to have_valid_field(:data, :attributes, :metadata)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                metadata: {
                  foo: "bar"
                }
              }
            }
          }
        )
      ).to have_valid_field(:data, :attributes, :metadata)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                metadata: nil
              }
            }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :metadata)

      expect(
        validate_request_schema(
          input_params: {
            data: {
              type: "phone_number",
              attributes: {
                metadata: "foo"
              }
            }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :metadata)
    end

    it "handles output for new records" do
      carrier = create(:carrier)

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              number: "+855715100987",
              type: "mobile",
              metadata: {
                foo: "bar"
              }
            }
          }
        },
        options: { carrier: }
      )

      expect(schema.output).to eq(
        carrier:,
        number: "855715100987",
        type: "mobile",
        metadata: { "foo" => "bar" }
      )
    end

    it "handles output for existing records" do
      carrier = create(:carrier, billing_currency: "CAD")
      phone_number = create(
        :phone_number,
        number: "12366130851",
        carrier:,
        iso_country_code: "US",
        visibility: :private,
        iso_region_code: "AR",
        locality: "Little Rock",
        rate_center: "LITTLEROCK",
        lata: "528"
      )

      schema = validate_request_schema(
        input_params: {
          data: {
            type: "phone_number",
            attributes: {
              visibility: "public",
              country: "CA",
              type: "mobile",
              price: "1.15",
              region: "ON",
              locality: "Toronto",
              rate_center: "newtoronto",
              lata: "888"
            }
          }
        },
        options: { carrier:, resource: phone_number }
      )

      expect(schema.output).to include(
        visibility: "public",
        iso_country_code: "CA",
        type: "mobile",
        price: Money.from_amount(1.15, "CAD"),
        iso_region_code: "ON",
        locality: "Toronto",
        rate_center: "NEWTORONTO",
        lata: "888"
      )
    end

    def validate_request_schema(input_params: {}, options: {})
      options.reverse_merge!(
        carrier: build_stubbed(:carrier)
      )
      PhoneNumberRequestSchema.new(input_params:, options:)
    end
  end
end
