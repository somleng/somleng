require "rails_helper"

RSpec.resource "Accounts", document: :twilio_api do
  get "https://api.somleng.org/2010-04-01/Accounts/:sid" do
    example "Fetch an account" do
      account = create(:account)

      set_twilio_api_authorization_header(account)
      do_request(sid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/account")
    end
  end
end
