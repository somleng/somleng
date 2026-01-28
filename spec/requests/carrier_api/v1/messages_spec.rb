require "rails_helper"

resource "Messages", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  get "https://api.somleng.org/carrier/v1/messages" do
    with_options scope: :filter do
      parameter(
        :account, "Return messages from the provided account-sid"
      )
      parameter(
        :from_date, "Return messages on or after the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format."
      )
      parameter(
        :to_date, "Return messages on or before the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format."
      )
      parameter(
        :direction,
        "One of #{MessageDecorator.directions.map { |direction| "`#{direction}`" }.to_sentence}"
      )
      parameter(
        :status,
        "One of #{MessageDecorator.statuses.map { |status| "`#{status}`" }.to_sentence}"
      )
    end

    example "List messages" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      other_account = create(:account, carrier:)
      message = create(
        :message,
        status: :sent, direction: :outbound_api, account:, created_at: Time.utc(2021, 11, 1, 1)
      )
      create(:message, status: message.status, account: message.account, direction: :inbound)
      create(:message, status: message.status, account: other_account, direction: message.direction)
      create(
        :message,
        account: message.account,
        status: message.status,
        direction: message.direction,
        created_at: Time.utc(2021, 11, 2, 1)
      )

      set_carrier_api_authorization_header(carrier)
      do_request(
        filter: {
          from_date: Time.utc(2021, 11, 1).iso8601,
          to_date: Time.utc(2021, 11, 1).iso8601,
          account: account.id,
          direction: "outbound-api",
          status: "sent"
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/message")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(message.id)
    end
  end

  get "https://api.somleng.org/carrier/v1/messages/:id" do
    example "Retrieve a message" do
      message = create(:message)

      set_carrier_api_authorization_header(message.carrier)
      do_request(id: message.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/message")
    end
  end

  patch "https://api.somleng.org/carrier/v1/messages/:id" do
    with_options scope: %i[data attributes] do
      parameter(
        :price, "The charge for this call in the account's billing currency"
      )
    end

    example "Update a message" do
      account = create(:account, billing_currency: "USD")
      message = create(:message, :sent, account:, price_cents: nil, price_unit: nil)

      set_carrier_api_authorization_header(message.carrier)
      do_request(
        id: message.id,
        data: {
          id: message.id,
          type: :message,
          attributes: {
            price: "-0.05"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/message")
      expect(json_response.dig("data", "attributes")).to include(
        "price" => "-0.05000",
        "price_unit" => "USD"
      )
    end
  end
end
