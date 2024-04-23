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
        :enabled,
        "Set to `false` to disable this number. Disabled phone numbers cannot be used by accounts. Enabled by default.",
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
    end

    with_options scope: %i[data relationships] do
      parameter(
        :account,
        "The `id` of the `account` to associate the phone number with."
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
        "country" => "KH"
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

    example "Create a phone number and assign it to an account" do
      carrier = create(:carrier)
      account = create(:account, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :phone_number,
          attributes: {
            number: "1294",
            type: "short_code"
          },
          relationships: {
            account: {
              data: {
                type: :account,
                id: account.id
              }
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(json_response.dig("data", "relationships", "account", "data", "id")).to eq(account.id)
    end
  end

  patch "https://api.somleng.org/carrier/v1/phone_numbers/:id" do
    with_options scope: %i[data relationships] do
      parameter(
        :account,
        "The `id` of the `account` to associate the phone number with."
      )
    end

    example "Assign an account to a phone number" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      phone_number = create(:phone_number, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(
        id: phone_number.id,
        data: {
          type: :phone_number,
          id: phone_number.id,
          relationships: {
            account: {
              data: {
                type: :account,
                id: account.id
              }
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(json_response.dig("data", "relationships", "account", "data", "id")).to eq(account.id)
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
        :enabled,
        "Set to `false` to disable the phone number or `true` to enable it. Disabled phone numbers cannot be used by accounts.",
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
        enabled: true,
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
            enabled: false,
            country: "US",
            price: "1.15"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(jsonapi_response_attributes).to include(
        "type" => "mobile",
        "enabled" => false,
        "country" => "US",
        "price" => "1.15",
        "currency" => "CAD"
      )
    end
  end

  patch "https://api.somleng.org/carrier/v1/phone_numbers/:id/release" do
    example "Release a phone number" do
      explanation "Releases a phone number by unassigning the account and removing any configuration."

      carrier = create(:carrier)
      account = create(:account, carrier:)
      phone_number = create(:phone_number, carrier:, account:)

      set_carrier_api_authorization_header(carrier)
      do_request(id: phone_number.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(json_response.dig("data", "relationships", "account", "data", "id")).to eq(nil)
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
      phone_number = create(:phone_number, :configured, carrier:)
      create(:phone_call, :inbound, phone_number:, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(id: phone_number.id)

      expect(response_status).to eq(204)
    end
  end
end
