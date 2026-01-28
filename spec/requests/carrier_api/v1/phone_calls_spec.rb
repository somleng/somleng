require "rails_helper"

resource "Phone Calls", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  get "https://api.somleng.org/carrier/v1/phone_calls" do
    with_options scope: :filter do
      parameter(
        :account, "Return phone calls from the provided `account-sid`"
      )
      parameter(
        :from_date, "Return phone calls on or after the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format."
      )
      parameter(
        :to_date, "Return phone calls on or before the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format."
      )
      parameter(
        :direction,
        "One of #{PhoneCallDecorator.directions.map { |direction| "`#{direction}`" }.to_sentence}"
      )
      parameter(
        :status,
        "One of #{PhoneCallDecorator.statuses.map { |status| "`#{status}`" }.to_sentence}"
      )
    end

    example "List phone calls" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      other_account = create(:account, carrier:)
      phone_call = create(
        :phone_call, :outbound, :initiated, account:, created_at: Time.utc(2021, 11, 1, 1)
      )
      create(
        :phone_call,
        :inbound,
        status: phone_call.status,
        account: phone_call.account,
        created_at: phone_call.created_at
      )
      create(
        :phone_call,
        :completed,
        direction: phone_call.direction,
        account: phone_call.account,
        created_at: phone_call.created_at
      )
      create(
        :phone_call,
        direction: phone_call.direction,
        status: phone_call.status,
        account: other_account,
        created_at: phone_call.created_at
      )
      create(
        :phone_call,
        direction: phone_call.direction,
        status: phone_call.status,
        account: phone_call.account,
        created_at: Time.utc(2021, 11, 2, 1)
      )

      set_carrier_api_authorization_header(carrier)
      do_request(
        filter: {
          from_date: Time.utc(2021, 11, 1).iso8601,
          to_date: Time.utc(2021, 11, 1).iso8601,
          account: account.id,
          direction: "outbound-api",
          status: "queued"
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/phone_call")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(phone_call.id)
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
        :price, "The charge for this call in the account's billing currency"
      )
    end

    example "Update a phone call" do
      account = create(:account, billing_currency: "USD")
      phone_call = create(:phone_call, :completed, account:, price_cents: nil, price_unit: nil)

      set_carrier_api_authorization_header(phone_call.carrier)
      do_request(
        id: phone_call.id,
        data: {
          id: phone_call.id,
          type: :phone_call,
          attributes: {
            price: "-0.05"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/phone_call")
      expect(json_response.dig("data", "attributes")).to include(
        "price" => "-0.05000",
        "price_unit" => "USD"
      )
    end
  end
end
