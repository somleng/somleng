require "rails_helper"

RSpec.describe "API Authentication" do
  it "requires http basic authentication" do
    account = create(:account)

    post(
      account_phone_calls_path(account)
    )

    expect(response.code).to eq("401")
    expect(response.headers["WWW-Authenticate"]).to eq(
      %(Bearer realm="Twilio API", error="invalid_token", error_description="The access token is invalid")
    )
  end

  it "denies unauthorized access" do
    account = create(:account)

    post(
      account_phone_calls_path(account),
      headers: build_authorization_headers("account", "wrong-password")
    )

    expect(response.code).to eq("401")
    expect(response.body).to match_api_response_schema(:api_errors)
  end

  it "denies access to a disabled account" do
    account = create(:account, :disabled)
    phone_call = create(:phone_call, account: account)

    get(
      account_phone_call_path(account, phone_call),
      headers: build_api_authorization_headers(account)
    )

    expect(response.code).to eq("401")
  end
end
