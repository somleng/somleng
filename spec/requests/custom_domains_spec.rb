require "rails_helper"

RSpec.describe "Custom Domains" do
  it "makes api requests" do
    account = create(:account)

    get(
      twilio_api_account_phone_calls_path(account),
      headers: build_api_authorization_headers(account).merge(
        headers_for_custom_domain(:api)
      )
    )

    expect(response.code).to eq("200")
  end

  it "allows requests to somleng.org" do
    carrier = create(:carrier)
    create(:custom_domain, :api, :verified, carrier:)
    account = create(:account, carrier:)

    get(
      twilio_api_account_phone_calls_path(account),
      headers: build_api_authorization_headers(account)
    )

    expect(response.code).to eq("200")
  end

  it "blocks cross-carrier API requests" do
    other_carrier = create(:carrier)
    carrier = create(:carrier)
    account = create(:account, carrier:)
    create(:custom_domain, :api, :verified, carrier: other_carrier, host: "xyz.example.com")

    get(
      twilio_api_account_phone_calls_path(account),
      headers: build_api_authorization_headers(account).merge(
        headers_for_custom_domain(
          :api,
          "X-Forwarded-Host" => "xyz.example.com"
        )
      )
    )

    expect(response.code).to eq("401")
  end

  it "makes dashboard requests" do
    get(
      new_user_session_path,
      headers: headers_for_custom_domain(:dashboard)
    )

    expect(response.code).to eq("200")
  end

  it "blocks requests to admin panel for custom domains" do
    expect {
      get(
        admin_root_path,
        headers: headers_for_custom_domain(:dashboard)
      )
    }.to raise_error(ActionController::RoutingError)
  end

  it "blocks requests to sign up for custom domains" do
    expect {
      get(
        new_user_registration_path,
        headers: headers_for_custom_domain(:dashboard)
      )
    }.to raise_error(ActionController::RoutingError)
  end

  it "displays carrier's logo under their custom domain name" do
    carrier = create(:carrier, :with_logo)
    create(:custom_domain, :dashboard, :verified, carrier:, host: "xyz.example.com")

    get(
      new_user_session_path,
      headers: headers_for_custom_domain(
        :dashboard,
        "X-Forwarded-Host" => "xyz.example.com"
      )
    )

    page = Capybara.string(response.body)
    expect(page).to have_css("img[alt=#{carrier.name}]")
  end

  it "displays customized carrier documentation" do
    carrier = create(:carrier, :with_logo, name: "AT&T")
    create(:custom_domain, :api, :verified, carrier:, host: "api.att.com")

    get(
      docs_path,
      headers: headers_for_custom_domain(
        :api,
        "X-Forwarded-Host" => "api.att.com"
      )
    )

    page = Capybara.string(response.body)
    expect(page).to have_css("img[alt='AT&T']")
    expect(page).to have_content("AT&T API Documentation")
    expect(page).to have_content("api.att.com")
  end

  it "returns 404 for unverified domains" do
    carrier = create(:carrier, :with_logo, name: "AT&T")
    create(:custom_domain, :api, carrier:, host: "api.att.com")

    get(
      docs_path,
      headers: headers_for_custom_domain(
        :api,
        "X-Forwarded-Host" => "api.att.com"
      )
    )

    expect(response.code).to eq("404")
  end

  it "redirects for requests to somleng.org" do
    get(docs_path)

    expect(response).to redirect_to("https://www.somleng.org/docs.html")
  end

  def headers_for_custom_domain(type, headers = {})
    host = URI(Rails.configuration.app_settings.fetch(:"#{type}_url_host")).host
    headers.reverse_merge(
      "Host" => host,
      "X-Forwarded-Host" => "xyz.example.com"
    )
  end
end
