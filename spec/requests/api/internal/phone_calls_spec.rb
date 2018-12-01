require "rails_helper"

RSpec.describe "Internal Phone Calls API" do
  describe "POST /api/internal/phone_calls" do
    it "creates a phone call" do
      params = build_request_params
      create(:incoming_phone_number, phone_number: params.fetch(:To))

      post(
        api_internal_phone_calls_path,
        params: params,
        headers: build_internal_api_authorization_headers
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_response_schema(:"api/internal/phone_call")
      expect(response.headers.fetch("Location")).to eq(api_internal_phone_call_url(PhoneCall.last))
    end

    it "handles input validation" do
      post(
        api_internal_phone_calls_path,
        params: {},
        headers: build_internal_api_authorization_headers
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_response_schema(:"api/error")
    end

    it "handles invalid requests" do
      params = build_request_params

      post(
        api_internal_phone_calls_path,
        params: params,
        headers: build_internal_api_authorization_headers
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_response_schema(:"api/error")
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
      expect(response.body).to match_response_schema(:"api/internal/phone_call")
    end
  end

  def build_request_params(params = {})
    params.reverse_merge(
      To: "2442",
      From: generate(:phone_number),
      ExternalSid: generate(:external_id),
      Variables: {
        "sip_from_host" => "103.9.189.2"
      }
    )
  end
end
