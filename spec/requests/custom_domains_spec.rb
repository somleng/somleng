require "rails_helper"

RSpec.xdescribe "Custom Domains" do
  it "makes api requests on custom domains" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    create(:custom_domain, :api, :verified, carrier:, host: "api.example.com")

    get(
      twilio_api_account_phone_calls_path(account),
      headers: build_api_authorization_headers(account).merge(
        headers_for_custom_domain(:api, "X-Forwarded-Host" => "api.example.com")
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

    expect {
      get(
        twilio_api_account_phone_calls_path(account),
        headers: build_api_authorization_headers(account).merge(
          headers_for_custom_domain(
            :api,
            "X-Forwarded-Host" => "xyz.example.com"
          )
        )
      )
    }.to raise_error(ActiveRecord::RecordNotFound)
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
    create(:custom_domain, :unverified, :api, carrier:, host: "api.att.com")

    expect {
      get(
        docs_path,
        headers: headers_for_custom_domain(
          :api,
          "X-Forwarded-Host" => "api.att.com"
        )
      )
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "redirects for requests to somleng.org" do
    get(docs_path)

    expect(response).to redirect_to("https://www.somleng.org/docs.html")
  end

  it "Blocks cross-domain login" do
    carrier = create(:carrier)
    user = create(:user, carrier:, password: "Super Secret")

    _other_carrier_domain = create(:custom_domain, :verified, :dashboard, host: "dashboard.example.com")
    post(
      user_session_path,
      params: {
        user: {
          email: user.email,
          password: "Super Secret",
          otp_attempt: user.current_otp
        }
      },
      headers: headers_for_custom_domain(
        :dashboard,
        "X-Forwarded-Host" => "dashboard.example.com"
      )
    )

    page = Capybara.string(response.body)
    expect(page).to have_content("Invalid Email or password")
  end

  it "Blocks unverified cross-domain requests" do
    carrier = create(:carrier)
    create(:custom_domain, :unverified, :dashboard, carrier:, host: "dashboard.example.com")

    expect {
      get(
        new_user_session_path,
        headers: headers_for_custom_domain(
          :dashboard,
          "X-Forwarded-Host" => "dashboard.example.com"
        )
      )
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "handles two users with the same email different carrier" do
    carrier1 = create(:carrier)
    carrier2 = create(:carrier)
    user1 = create(:user, name: "User1", carrier: carrier1, password: "Super Secret")
    user2 = create(:user, name: "User2", carrier: carrier2, email: user1.email, password: "Super Secret")

    create(:custom_domain, :verified, :dashboard, carrier: carrier1, host: "dashboard.another-example.com")
    create(:custom_domain, :verified, :dashboard, carrier: carrier2, host: "dashboard.example.com")

    post(
      user_session_path,
      params: {
        user: {
          email: user2.email,
          password: "Super Secret",
          otp_attempt: user2.current_otp
        }
      },
      headers: headers_for_custom_domain(
        :dashboard,
        "X-Forwarded-Host" => "dashboard.example.com"
      )
    )

    expect(response).to redirect_to("http://dashboard.example.com/")
  end

  it "handles OTP correctly for cross domain requests" do
    carrier = create(:carrier)
    create(:custom_domain, :verified, :dashboard, carrier:, host: "dashboard.example.com")
    carrier_user = create(:user, :carrier, carrier:, password: "Super Secret")
    account_user = create(:user, carrier:, password: "Super Secret")

    post(
      user_session_path,
      params: {
        user: {
          email: account_user.email,
          password: "Super Secret",
          otp_attempt: carrier_user.current_otp
        }
      },
      headers: headers_for_custom_domain(
        :dashboard,
        "X-Forwarded-Host" => "dashboard.example.com"
      )
    )

    page = Capybara.string(response.body)
    expect(page).to have_content("Invalid Email or password")
  end

  def headers_for_custom_domain(type, headers = {})
    host = URI(Rails.configuration.app_settings.fetch(:"#{type}_url_host")).host
    headers.reverse_merge(
      "Host" => host,
      "X-Forwarded-Host" => "xyz.example.com"
    )
  end
end
