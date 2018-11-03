require "rails_helper"

RSpec.describe "Phone Calls API" do
  describe "POST /api/2010-04-01/Accounts/{AccountSid}/Calls" do
    # https://www.twilio.com/docs/api/rest/making-calls

    it "creates a phone call" do
      params = {
        "Url" => "https://rapidpro.ngrok.com/handle/33/",
        "Method" => "GET",
        "To" => "+855715100860",
        "From" => "2442",
        "StatusCallback" => "https://rapidpro.ngrok.com/handle/33/",
        "StatusCallbackMethod" => "GET"
      }

      post(
        api_twilio_account_calls_path(account_sid),
        params: params,
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("201")
      expect(parsed_response_body.fetch("to")).to eq("+855715100860")
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
      expect(parsed_response_body).to eq(phone_call.as_json)
    end
  end
end
