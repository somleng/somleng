require "rails_helper"

resource "Phone Numbers", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  post "https://api.somleng.org/carrier/v1/phone_numbers" do
    with_options scope: %i[data attributes] do
      parameter(
        :number,
        "Phone number in E.164 format or shortcode.",
        required: true
      )
      parameter(
        :type,
        "The type of the phone number. Must be one of #{PhoneNumber.type.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: true
      )
      parameter(
        :visibility,
        "The visibility of the phone number. Must be one of #{PhoneNumber.visibility.values.map { |v| "`#{v}`" }.join(", ")}. Defaults to `public` for phone numbers with a price and `private` for phone numbers without one",
        required: false
      )
      parameter(
        :country,
        "The ISO 3166-1 alpha-2 country code of the phone number. If not specified, it's automatically resolved from the `number` parameter, or defaults to the carrier's country code if unresolvable.",
        required: false
      )
      parameter(
        :price,
        "The price for the phone number in the billing currency of the carrier.",
        required: false
      )
      parameter(
        :region,
        "The state or province abbreviation of this phone number's location.",
        required: false
      )
      parameter(
        :locality,
        "The locality or city of this phone number's location.",
        required: false
      )
      parameter(
        :lata,
        "The [LATA](https://en.wikipedia.org/wiki/Local_access_and_transport_area) of this phone number. Applicable only to phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :rate_center,
        "The [rate center](https://en.wikipedia.org/wiki/Rate_center) of this phone number. Applicable only to phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :latitude,
        "The latitude of this phone number's location. Applicable only for phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :longitude,
        "The longitude of this phone number's location. Applicable only for phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :metadata,
        "Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format.",
        required: false
      )
    end

    example "01. Create a phone number" do
      carrier = create(:carrier, country_code: "KH")

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :phone_number,
          attributes: {
            number: "1294",
            type: "short_code",
            metadata: {
              my_custom_field: "my_custom_field_value"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(jsonapi_response_attributes).to include(
        "number" => "1294",
        "country" => "KH",
        "visibility" => "private",
        "metadata" => {
          "my_custom_field" => "my_custom_field_value"
        }
      )
    end

    example "Handles invalid requests", document: false do
      carrier = create(:carrier, country_code: "KH")

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :phone_number,
          attributes: {
            number: "1294",
            type: "local"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
    end
  end

  patch "https://api.somleng.org/carrier/v1/phone_numbers/:id" do
    with_options scope: %i[data attributes] do
      parameter(
        :type,
        "The type of the phone number. Must be one of #{PhoneNumber.type.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: false
      )
      parameter(
        :visibility,
        "The visibility of the phone number. Must be one of #{PhoneNumber.visibility.values.map { |v| "`#{v}`" }.join(", ")}. Defaults to `public` for phone numbers with a price and `private` for phone numbers without one",
        required: false
      )
      parameter(
        :country,
        "The ISO 3166-1 alpha-2 country code of the phone number. If not specified, it's automatically resolved from the `number` parameter, or defaults to the carrier's country code if unresolvable.",
        required: false
      )
      parameter(
        :price,
        "The price for the phone number in the billing currency of the carrier.",
        required: false
      )
      parameter(
        :region,
        "The state or province abbreviation of this phone number's location.",
        required: false
      )
      parameter(
        :locality,
        "The locality or city of this phone number's location.",
        required: false
      )
      parameter(
        :lata,
        "The [LATA](https://en.wikipedia.org/wiki/Local_access_and_transport_area) of this phone number. Applicable only to phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :rate_center,
        "The [rate center](https://en.wikipedia.org/wiki/Rate_center) of this phone number. Applicable only to phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :latitude,
        "The latitude of this phone number's location. Applicable only for phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :longitude,
        "The longitude of this phone number's location. Applicable only for phone numbers from the US and Canada.",
        required: false
      )
      parameter(
        :metadata,
        "Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format.",
        required: false
      )
    end

    example "02. Update a phone number" do
      carrier = create(:carrier, billing_currency: "CAD")
      phone_number = create(
        :phone_number,
        number: "15067020972",
        iso_country_code: "CA",
        visibility: :private,
        type: "mobile",
        carrier:
      )

      set_carrier_api_authorization_header(carrier)
      do_request(
        id: phone_number.id,
        data: {
          type: :phone_number,
          id: phone_number.id,
          attributes: {
            type: "mobile",
            visibility: "public",
            country: "US",
            price: "1.15",
            region: "AR",
            locality: "Little Rock",
            rate_center: "LITTLEROCK",
            lata: "528",
            latitude: "34.748463",
            longitude: "-92.284434",
            metadata: {
              my_custom_field: "my_custom_field_value"
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(jsonapi_response_attributes).to include(
        "type" => "mobile",
        "visibility" => "public",
        "country" => "US",
        "price" => "1.15",
        "currency" => "CAD",
        "region" => "AR",
        "locality" => "Little Rock",
        "lata" => "528",
        "rate_center" => "LITTLEROCK",
        "latitude" => "34.748463",
        "longitude" => "-92.284434",
        "metadata" => {
          "my_custom_field" => "my_custom_field_value"
        }
      )
    end
  end

  get "https://api.somleng.org/carrier/v1/phone_numbers/:id" do
    example "03. Retrieve a phone number" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(id: phone_number.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
    end
  end

  get "https://api.somleng.org/carrier/v1/phone_numbers" do
    example "04. List all phone numbers" do
      carrier = create(:carrier)
      phone_numbers = create_list(:phone_number, 2, carrier:)
      _other_phone_number = create(:phone_number)

      set_carrier_api_authorization_header(carrier)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/phone_number")
      expect(json_response.fetch("data").pluck("id")).to match_array(phone_numbers.pluck(:id))
    end
  end

  delete "https://api.somleng.org/carrier/v1/phone_numbers/:id" do
    example "05. Delete a phone number" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, carrier:)
      create(:phone_call, :inbound, phone_number:, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(id: phone_number.id)

      expect(response_status).to eq(204)
    end
  end

  get "https://api.somleng.org/carrier/v1/phone_numbers/stats" do
    with_options scope: :filter do
      parameter(
        :available, "Return only available phone numbers. Must be `true`",
        required: true
      )
      parameter(
        :type, "The phone number type. Must be `local`",
        required: true
      )
      parameter(
        :country, "The ISO country code. E.g. `US`",
        required: false
      )
      parameter(
        :region, "The ISO region code. E.g. `AR`",
        required: false
      )
      parameter(
        :locality, "The locality or city name. e.g. `Little Rock`",
        required: false
      )
    end

    parameter(
      :group_by,
      "An array of fields to group by. Must be `['country', 'region', 'locality']`",
      required: true
    )

    with_options scope: [ :having, :count ] do
      parameter(
        :operator, "One of `eq`, `neq`, `gt`, `gteq`, `lt`, `lteq`"
      )
      parameter(
        :value, "The value of the count. Must be an integer greater than or equal to 0"
      )
    end

    example "06. Get number of available phone numbers per locality having a count less than 2" do
      carrier = create(:carrier)
      create(:phone_number, carrier:, type: :local, number: "12513095500", iso_country_code: "US", iso_region_code: "AR", locality: "Little Rock")
      create(:phone_number, carrier:, type: :local, number: "12513095501", iso_country_code: "US", iso_region_code: "AR", locality: "Little Rock")
      create(:phone_number, carrier:, type: :local, number: "12513095502", iso_country_code: "US", iso_region_code: "AR", locality: "Hot Springs")
      create(:phone_number, carrier:, type: :local, number: "12513095503", iso_country_code: "US", iso_region_code: "AL", locality: "Tuscaloosa")
      create(:phone_number, carrier:, type: :local, number: "12513095504", iso_country_code: "US", iso_region_code: "AL", locality: "Birmingham")
      create(:phone_number, carrier:, type: :local, number: "12513095505", iso_country_code: "US", iso_region_code: "AL", locality: "Huntsville")
      create(:phone_number, carrier:, type: :local, number: "12513095506", iso_country_code: "US")

      set_carrier_api_authorization_header(carrier)
      do_request(
        filter: {
          available: true,
          type: :local
        },
        group_by: [ "country", "region", "locality" ],
        having: {
          count: { lt: 2 }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/aggregate_data")
      statistics = json_response.fetch("data").map { |data| data.dig("attributes", "statistic") }

      expect(statistics).to eq(
        [
          {
            "country" => "US",
            "region" => "AL",
            "locality" => "Birmingham",
            "value" => 1
          },
          {
            "country" => "US",
            "region" => "AL",
            "locality" => "Huntsville",
            "value" => 1
          },
          {
            "country" => "US",
            "region" => "AL",
            "locality" => "Tuscaloosa",
            "value" => 1
          },
          {
            "country" => "US",
            "region" => "AR",
            "locality" => "Hot Springs",
            "value" => 1
          },
          {
            "country" => "US",
            "region" => nil,
            "locality" => nil,
            "value" => 1
          }
        ]
      )
    end

    example "Handles invalid requests", document: false do
      carrier = create(:carrier)

      set_carrier_api_authorization_header(carrier)
      do_request

      expect(response_status).to eq(400)
    end

    example "Handles pagination", document: false do
      carrier = create(:carrier)
      create(:phone_number, carrier:, type: :local, number: "12513095500", iso_country_code: "US", iso_region_code: "AL", locality: "Tuscaloosa")
      create(:phone_number, carrier:, type: :local, number: "12513095501", iso_country_code: "US", iso_region_code: "AL", locality: "Birmingham")
      create(:phone_number, carrier:, type: :local, number: "12513095502", iso_country_code: "US", iso_region_code: "AL", locality: "Huntsville")

      set_carrier_api_authorization_header(carrier)
      do_request(
        filter: {
          available: true,
          type: :local
        },
        group_by: [ "country", "region", "locality" ],
        page: {
          after: AggregateData::IDGenerator.new.generate_id([ "US", "AL", "Birmingham" ])
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/aggregate_data")
      statistics = json_response.fetch("data").map { |data| data.dig("attributes", "statistic") }

      expect(statistics).to eq(
        [
          {
            "country" => "US",
            "region" => "AL",
            "locality" => "Huntsville",
            "value" => 1
          },
          {
            "country" => "US",
            "region" => "AL",
            "locality" => "Tuscaloosa",
            "value" => 1
          }
        ]
      )
    end
  end
end
