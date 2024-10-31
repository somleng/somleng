require "rails_helper"

RSpec.resource "Accounts", document: :twilio_api do
  get "https://api.somleng.org/2010-04-01/Accounts/:Sid" do
    parameter(
      "Sid",
      "*Path Parameter*: The Account Sid that uniquely identifies the account to fetch."
    )

    # https://www.twilio.com/docs/iam/api/account#fetch-an-account
    example "01. Fetch an account" do
      explanation <<~HEREDOC
        Returns a representation of an account, including the properties above.
      HEREDOC

      account = create(:account, name: "Rocket Rides")

      set_twilio_api_authorization_header(account)
      do_request(Sid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/account")
      expect(json_response).to include(
        "sid" => account.id,
        "owner_account_sid" => account.id,
        "friendly_name" => "Rocket Rides"
      )
    end
  end
end
