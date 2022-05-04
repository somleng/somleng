require "rails_helper"

RSpec.describe "Custom Domain Name", type: :request do
  it "makes request to api.somleng.org" do
    account = create(:account)

    get(
      twilio_api_account_phone_calls_path(account),
      headers: build_api_authorization_headers(account).merge(
        "HOST" => "api.somleng.org",
        "X-Forwarded-Host" => "xyz.example.com"
      )
    )

    expect(response.code).to eq("200")
  end

  it "makes request to dashboard.somleng.org" do
    get(
      new_user_session_path,
      headers: {
        "HOST" => "dashboard.somleng.org",
        "X-Forwarded-Host" => "xyz.example.com"
      }
    )

    expect(response.code).to eq("200")
  end

  it "displays carrier's logo under their custom domain name" do
    carrier = create(:carrier, :with_logo)
    create(:custom_domain_name, :dashboard, :verified, carrier:, host: "xyz.example.com")

    get new_user_session_path, headers: {
      "HOST" => "dashboard.somleng.org",
      "X-Forwarded-Host" => "xyz.example.com"
    }

    binding.pry
  end
end
