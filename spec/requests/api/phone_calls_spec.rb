require "rails_helper"

RSpec.describe "Phone Calls API" do
  describe "POST /api/2010-04-01/Accounts/{AccountSid}/Calls" do
    # https://www.twilio.com/docs/api/rest/making-calls

    it "creates a phone call" do
      external_id = SecureRandom.uuid
      stub_drb_object(initiate_outbound_call!: external_id)

      params = {
        "Url" => "https://rapidpro.ngrok.com/handle/33/",
        "Method" => "GET",
        "To" => "+855715100860",
        "From" => "2442",
        "StatusCallback" => "https://rapidpro.ngrok.com/handle/33/",
        "StatusCallbackMethod" => "GET"
      }

      perform_enqueued_jobs do
        post(
          api_twilio_account_calls_path(account_sid),
          params: params,
          headers: build_api_authorization_headers(account)
        )
      end

      expect(response.code).to eq("201")
      expect(response.body).to match_response_schema(:"api/phone_call")
      phone_call = PhoneCall.find(JSON.parse(response.body).fetch("sid"))
      expect(phone_call).to be_initiated
      expect(phone_call.external_id).to eq(external_id)
    end

    it "handles invalid requests" do
      params = {}

      post(
        api_twilio_account_calls_path(account_sid),
        params: params,
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_response_schema(:"api/error")
      expect(JSON.parse(response.body).fetch("status")).to eq(422)
    end
  end

  describe "GET '/api/2010-04-01/Accounts/{AccountSid}/Calls/{CallSid}'" do
    # https://www.twilio.com/docs/api/rest/call#instance-get

    it "gets a phone call" do
      account = create(:account)
      phone_call = create(:phone_call, account: account)

      get(
        api_twilio_account_call_path(account, phone_call),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_response_schema(:"api/phone_call")
    end
  end
end
