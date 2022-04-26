require "rails_helper"

RSpec.describe "Twilio API Authentication" do
  it "requires http basic authentication" do
    account = create(:account)

    post(
      twilio_api_account_phone_calls_path(account)
    )

    expect(response.code).to eq("401")
    expect(response.headers["WWW-Authenticate"]).to eq(
      %(Bearer realm="Twilio API", error="invalid_token", error_description="The access token is invalid")
    )
  end

  it "denies unauthorized access" do
    account = create(:account)

    post(
      twilio_api_account_phone_calls_path(account),
      headers: build_authorization_headers("account", "wrong-password")
    )

    expect(response.code).to eq("401")
    expect(response.body).to match_api_response_schema("twilio_api/api_errors")
  end

  it "denies access if account sid is incorrect" do
    account = create(:account)

    post(
      twilio_api_account_phone_calls_path(account),
      headers: build_authorization_headers("wrong-account-id", account.auth_token)
    )

    expect(response.code).to eq("401")
  end

  it "denies access to a disabled account" do
    account = create(:account, :disabled)
    phone_call = create(:phone_call, account:)

    get(
      twilio_api_account_phone_call_path(account, phone_call),
      headers: build_api_authorization_headers(account)
    )

    expect(response.code).to eq("401")
  end

  it "denies access for carriers that are not in good standing" do
    carrier = create_restricted_carrier
    account = create(:account, carrier:)

    get(
      twilio_api_account_phone_calls_path(account),
      headers: build_api_authorization_headers(account)
    )

    expect(response.code).to eq("401")
  end
end
