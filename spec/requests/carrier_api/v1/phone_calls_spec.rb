require "rails_helper"

resource "Phone Calls", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  get "https://api.somleng.org/carrier/v1/phone_calls" do
    with_options scope: :filter do
      parameter(
        :account, "Return phone calls from the provided account-sid",
      )
      parameter(
        :from_date, "Return phone calls on or after the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format.",
      )
      parameter(
        :to_date, "Return phone calls on or before the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format.",
      )
    end

    example "List phone calls" do
      carrier = create(:carrier)
      account = create(:account, carrier: carrier)
      other_account = create(:account, carrier: carrier)
      outbound_call = create(
        :phone_call, :outbound, account: account, created_at: Time.utc(2021, 11, 1, 1)
      )
      _inbound_call = create(
        :phone_call, :inbound, account: account, created_at: Time.utc(2021, 11, 1, 1)
      )
      _phone_call_from_another_account = create(:phone_call, account: other_account)
      _phone_call_outside_of_date_range = create(:phone_call, account: account, created_at: Time.utc(2021, 11, 1, 12))

      set_carrier_api_authorization_header(carrier)
      do_request(
        filter: {
          from_date: Time.utc(2021, 11, 1).iso8601,
          to_date: Time.utc(2021, 11, 1, 11).iso8601,
          account: account.id,
          direction: "outbound-api"
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/phone_call")
      expect(json_response.fetch("data").pluck("id")).to match_array([outbound_call.id])
    end
  end

  get "https://api.somleng.org/carrier/v1/phone_calls/:id" do
    example "Retrieve a phone call" do
      phone_call = create(:phone_call)

      set_carrier_api_authorization_header(phone_call.carrier)
      do_request(id: phone_call.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_call")
    end
  end

  patch "https://api.somleng.org/carrier/v1/phone_calls/:id" do
    with_options scope: %i[data attributes] do
      parameter(
        :price, "The charge for this call."
      )
      parameter(
        :price_unit, "The currency in which `price`` is measured, in <a href=\"https://www.iso.org/iso/home/standards/currency_codes.htm\">ISO 4127 </a> format. (e.g., `USD`, `EUR`, `JPY`). Always capitalized for calls.",
      )
    end

    example "Update a phone call" do
      phone_call = create(:phone_call, price: nil, price_unit: nil)

      set_carrier_api_authorization_header(phone_call.carrier)
      do_request(
        id: phone_call.id,
        data: {
          id: phone_call.id,
          type: :phone_call,
          attributes: {
            price: "-0.05",
            price_unit: "USD"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_call")
      expect(json_response.dig("data", "attributes")).to include(
        "price" => "-0.05",
        "price_unit" => "USD"
      )
    end
  end
end
