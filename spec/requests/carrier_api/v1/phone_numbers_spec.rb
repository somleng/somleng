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
    end

    example "Create a phone number" do
      carrier = create(:carrier, country_code: "KH")

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :phone_number,
          attributes: {
            number: "1294",
            type: "short_code"
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(jsonapi_response_attributes).to include(
        "number" => "1294",
        "country" => "KH",
        "visibility" => "private"
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
        "Must be one of #{PhoneNumber.type.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: false
      )

      parameter(
        :visibility,
        "The visibility of the phone number. Must be one of #{PhoneNumber.visibility.values.map { |v| "`#{v}`" }.join(", ")}. Defaults to `public` for phone numbers with a price and `private` for phone numbers without one",
        required: false
      )

      parameter(
        :country,
        "The ISO 3166-1 alpha-2 country code of the phone number.",
        required: false
      )

      parameter(
        :price,
        "The price for the phone number in the billing currency of the carrier.",
        required: false
      )
    end

    example "Update a phone number" do
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
            region: "AK",
            locality: "Little Rock"
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
        "region" => "AK",
        "locality" => "Little Rock"
      )
    end
  end

  get "https://api.somleng.org/carrier/v1/phone_numbers/:id" do
    example "Retrieve a phone number" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(id: phone_number.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
    end
  end

  get "https://api.somleng.org/carrier/v1/phone_numbers" do
    example "List all phone numbers" do
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
    example "Delete a phone number" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, carrier:)
      create(:phone_call, :inbound, phone_number:, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(id: phone_number.id)

      expect(response_status).to eq(204)
    end
  end
end
