require "rails_helper"

resource "Accounts", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  post "https://api.somleng.org/carrier/v1/accounts" do
    with_options scope: %i[data attributes] do
      parameter(
        :name,
        "A friendly name which identifies the account",
        required: true
      )
      parameter(
        :tts_voice,
        "The default TTS voice identifier. Defaults to: #{TTSVoices::Voice.default.identifier}"
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
            default_tts_voice: "Basic.Kal",
            metadata: {
              foo: "bar"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/account")
      expect(jsonapi_response_attributes.fetch("name")).to eq("Rocket Rides")
      expect(jsonapi_response_attributes.fetch("type")).to eq("carrier_managed")
      expect(jsonapi_response_attributes.fetch("default_tts_voice")).to eq("Basic.Kal")
    end

    example "handles invalid requests", document: false do
      carrier = create(:carrier)

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :account,
          attributes: {
            name: nil
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
    end
  end

  patch "https://api.somleng.org/carrier/v1/accounts/:id" do
    with_options scope: %i[data attributes] do
      parameter(
        :status,
        "Update the status of the account. One of either `enabled` or `disabled`."
      )
    end

    example "Update an account" do
      account = create(
        :account,
        name: "Rocket Rides",
        status: :enabled,
        default_tts_voice: "Basic.Slt",
        metadata: { "foo" => "bar" }
      )

      set_carrier_api_authorization_header(
        account.carrier
      )
      do_request(
        id: account.id,
        data: {
          type: :account,
          id: account.id,
          attributes: {
            name: "Bob Cats",
            status: "disabled",
            default_tts_voice: "Basic.Kal",
            metadata: {
              "bar" => "foo"
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/account")
      expect(jsonapi_response_attributes).to include(
        "status" => "disabled",
        "default_tts_voice" => "Basic.Kal",
        "metadata" => {
          "bar" => "foo",
          "foo" => "bar"
        }
      )
    end

    example "Handles invalid requests", document: false do
      account = create(:account, :customer_managed)

      set_carrier_api_authorization_header(
        account.carrier
      )
      do_request(
        id: account.id,
        data: {
          type: :account,
          id: account.id,
          attributes: {
            name: "Bob Cats",
            default_tts_voice: "Basic.Kal"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(
        json_response.fetch("errors").pluck("source").pluck("pointer")
      ).to include(
        "/data/attributes/name",
        "/data/attributes/default_tts_voice"
      )
    end
  end

  get "https://api.somleng.org/carrier/v1/accounts/:id" do
    parameter(
      :id,
      "The `id` of the account to be retrieved.",
      required: true
    )

    example "Retrieve an account" do
      account = create(:account)

      set_carrier_api_authorization_header(account.carrier)
      do_request(id: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/account")
    end
  end

  get "https://api.somleng.org/carrier/v1/accounts" do
    example "List all accounts" do
      carrier = create(:carrier)
      customer_managed_account = create(:account, :customer_managed, name: "Rocket Rides", carrier:)
      carrier_managed_account = create(:account, :carrier_managed, name: "Telco Net", carrier:)
      _other_account = create(:account)

      set_carrier_api_authorization_header(carrier)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/account")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        customer_managed_account.id, carrier_managed_account.id
      )
      expect(
        json_response.dig(
          "data", 0, "attributes",
          "auth_token"
        )
      ).to eq(carrier_managed_account.auth_token)
      expect(
        json_response.dig("data", 1, "attributes").key?("auth_token")
      ).to be(false)
    end
  end

  delete "https://api.somleng.org/carrier/v1/accounts/:id" do
    example "Delete an account" do
      carrier = create(:carrier)
      account = create(:account, carrier:)

      stub_rating_engine_request
      set_carrier_api_authorization_header(carrier)
      do_request(id: account.id)

      expect(response_status).to eq(204)
    end

    example "Delete an account with phone calls", document: false do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      create(:phone_call, account:)

      set_carrier_api_authorization_header(carrier)
      do_request(id: account.id)

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
    end
  end
end
