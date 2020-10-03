require "rails_helper"

RSpec.describe "Phone Calls API" do
  describe "POST /api/2010-04-01/Accounts/{AccountSid}/Calls" do
    # https://www.twilio.com/docs/api/rest/making-calls

    it "creates a phone call" do
      account = create(:account)

      post(
        api_account_phone_calls_path(account),
        params: {
          "Url" => "https://rapidpro.ngrok.com/handle/33/",
          "Method" => "GET",
          "To" => "+855715100860",
          "From" => "2442",
          "StatusCallback" => "https://rapidpro.ngrok.com/handle/33/",
          "StatusCallbackMethod" => "GET"
        },
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema(:phone_call)
    end

    it "handles invalid requests" do
      account = create(:account)

      post(
        api_account_phone_calls_path(account),
        params: {},
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema(:api_errors)
    end
  end

  describe "GET '/api/2010-04-01/Accounts/{AccountSid}/Calls/{CallSid}'" do
    # https://www.twilio.com/docs/api/rest/call#instance-get

    it "gets a phone call" do
      account = create(:account)
      phone_call = create(:phone_call, account: account)

      get(
        api_account_phone_call_path(account, phone_call),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_api_response_schema(:phone_call)
    end
  end
end
