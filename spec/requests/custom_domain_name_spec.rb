require "rails_helper"

RSpec.describe "Custom Domain Name" do
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

  it "blocks requests to admin panel for custom domains" do
    expect {
      get(
        admin_root_path,
        headers: {
          "HOST" => "dashboard.somleng.org",
          "X-Forwarded-Host" => "xyz.example.com"
        }
      )
    }.to raise_error(ActionController::RoutingError)
  end

  it "blocks requests to sign up for custom domains" do
    expect {
      get(
        new_user_registration_path,
        headers: {
          "HOST" => "dashboard.somleng.org",
          "X-Forwarded-Host" => "xyz.example.com"
        }
      )
    }.to raise_error(ActionController::RoutingError)
  end

  it "displays carrier's logo under their custom domain name" do
    carrier = create(:carrier, :with_logo)
    create(:custom_domain_name, :dashboard, :verified, carrier:, host: "xyz.example.com")

    get(
      new_user_session_path,
      headers: {
        "HOST" => "dashboard.somleng.org",
        "X-Forwarded-Host" => "xyz.example.com"
      }
    )

    page = Capybara.string(response.body)
    expect(page).to have_css("img[alt=#{carrier.name}]")
  end
end
