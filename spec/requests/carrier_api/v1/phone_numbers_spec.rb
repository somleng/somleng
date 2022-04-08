require "rails_helper"

resource "Phone Numbers", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  post "https://api.somleng.org/carrier/v1/phone_numbers" do
    with_options scope: %i[data attributes] do
      parameter(
        :number,
        "The phone number in E.164 format, which consists of a + followed by the country code and subscriber number, or a short code.",
        required: true
      )
      parameter(
        :voice_url,
        "The absolute URL that returns the TwiML instructions for the call. We will call this URL using the `method` when the call connects.",
        required: false,
        example: "https://demo.twilio.com/docs/voice.xml"
      )
      parameter(
        :voice_method,
        "The HTTP method we should use when calling the url parameter's value. Can be: `GET` or `POST` and the default is `POST`.",
        required: false,
        example: "GET"
      )
      parameter(
        :status_callback_url,
        "The URL we should call using the `status_callback_method` to send status information to your application. URLs must contain a valid hostname (underscores are not permitted).",
        required: false,
        example: "https://example.com/status_callback"
      )
      parameter(
        :status_callback_method,
        "The HTTP method we should use when calling the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
        required: false,
        example: "POST"
      )
    end

    with_options scope: %i[data relationships] do
      parameter(
        :account,
        "The `id` of the `account` in which the phone number will be created for"
      )
    end

    example "Create a phone number" do
      carrier = create(:carrier)
      account = create(:account, carrier:)

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :phone_number,
          attributes: {
            number: "1294",
            voice_url: "https://demo.twilio.com/docs/voice.xml",
            voice_method: "GET"
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
      expect(jsonapi_response_attributes).to include(
        "number" => "1294",
        "voice_url" => "https://demo.twilio.com/docs/voice.xml",
        "voice_method" => "GET"
      )
      expect(json_response.dig("data", "relationships", "account", "data", "id")).to eq(account.id)
    end
  end

  patch "https://api.somleng.org/carrier/v1/phone_numbers/:id" do
    example "Update a phone number" do
      carrier = create(:carrier)
      phone_number = create(:phone_number, carrier:, number: "1000")

      set_carrier_api_authorization_header(carrier)
      do_request(
        id: phone_number.id,
        data: {
          type: :phone_number,
          id: phone_number.id,
          attributes: {
            number: "1294"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_number")
      expect(jsonapi_response_attributes.fetch("number")).to eq("1294")
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
end
