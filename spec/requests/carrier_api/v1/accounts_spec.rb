require "rails_helper"

resource "Accounts", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  post "/carrier/v1/accounts" do
    with_options scope: %i[data attributes] do
      parameter(
        :name,
        "A friendly name which identifies the account",
        required: true
      )
      parameter(
        :metadata,
        "Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format."
      )
    end

    example "Create an account" do
      carrier = create(:carrier)

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :account,
          attributes: {
            name: "Rocket Rides",
            metadata: {
              foo: "bar"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_resource_schema(:account)
      expect(response_attributes.fetch("name")).to eq("Rocket Rides")
    end

    example "handles invalid requests", document: false do
      carrier = create(:carrier)

      set_carrier_authorization_header(carrier)
      do_request(
        data: {
          type: :account,
          attributes: {
            name: nil
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema(:api_error)
    end
  end

  patch "/v1/accounts/:id" do
    example "Update an account" do
      account = create(:account, metadata: { "foo" => "bar" })

      set_carrier_authorization_header(
        account.carrier
      )
      do_request(
        id: account.id,
        data: {
          type: :account,
          id: account.id,
          attributes: {
            metadata: {
              "bar" => "foo"
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_resource_schema(:account)
      expect(response_attributes).to include(
        "metadata" => {
          "bar" => "foo",
          "foo" => "bar"
        }
      )
    end
  end

  get "/v1/accounts/:id" do
    parameter(
      :id,
      "The `id` of the account to be retrieved.",
      required: true
    )

    example "Retrieve an account" do
      account = create(:account)

      set_carrier_authorization_header(account.carrier)
      do_request(id: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_resource_schema(:account)
    end
  end

  get "/v1/accounts" do
    example "List all accounts" do
      carrier = create(:carrier)
      accounts = create_list(:account, 2, carrier: carrier)
      _other_account = create(:account)

      set_carrier_authorization_header(carrier)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_api_resource_collection_schema(:account)
      expect(json_response.fetch("data").pluck("id")).to match_array(accounts.map(&:id))
    end
  end
end
