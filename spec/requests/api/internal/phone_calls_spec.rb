require "rails_helper"

RSpec.describe "Internal Phone Calls API" do
  describe "POST /api/internal/phone_calls" do
    fit "creates a phone call" do
      params = {
        "To" => generate(:phone_number),
        "From" => "2442",
        "ExternalSid" => generate(:external_id),
        "Variables" => {
          "sip_from_host" => "103.9.189.2"
        }
      }

      create(:incoming_phone_number, phone_number: params.fetch("To"))

      post(
        api_internal_phone_calls_path,
        params: params,
        headers: build_internal_api_authorization_headers
      )

      # TODO: Use JSON schema
      p response.body
      expect(response.code).to eq("201")
      expect(JSON.parse(response.body).fetch("from")).to eq(params.fetch("From"))
    end
  end

  describe "GET /api/internal/phone_calls/:id" do
    it "gets a phone call" do
      phone_call = create(:phone_call)

      get(
        api_internal_phone_call_path(phone_call),
        headers: build_internal_api_authorization_headers
      )

      expect(response.code).to eq("200")
      expect(response.body).to eq(phone_call.to_internal_inbound_call_json)
    end
  end
end
