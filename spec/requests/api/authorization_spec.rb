require "rails_helper"

RSpec.describe "API Authorization" do
  it "requires http basic authentication" do
    account = create(:account)

    post(
      api_twilio_account_calls_path(account)
    )

    expect(response.code).to eq("401")
    expect(response.headers["WWW-Authenticate"]).to eq("Basic realm=\"Twilio API\"")
  end

  it "denies unauthorized access" do
    account = create(:account)

    post(
      api_twilio_account_calls_path(account),
      headers: build_authorization_headers("account", "wrong-password"),
    )

    expect(response.code).to eq("401")
  end

  it "denies access to a disabled account" do
    account = create(:account, :disabled)

    phone_call = create(:phone_call, account: account)

    get(
      api_twilio_account_call_path(account, phone_call),
      headers: build_api_authorization_headers(account)
    )

    expect(response.code).to eq("401")
  end
end
