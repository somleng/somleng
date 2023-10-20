require "rails_helper"

RSpec.describe "Routes" do
  it "blocks requests to admin panel for custom domains" do
    get(admin_root_path)

    expect(response).to have_http_status(:not_found)
  end

  it "blocks requests to sign up for subdomains" do
    get(new_user_registration_path)

    expect(response).to have_http_status(:not_found)
  end

  it "redirects docs to somleng.org" do
    carrier = create(:carrier)

    get(docs_url(host: carrier.subdomain_host))

    expect(response).to redirect_to("https://www.somleng.org/docs.html")
  end

  it "serves customized documentation" do
    create(:carrier, subdomain: "at-t")

    get(
      docs_twilio_api_path,
      headers: {
        "Host" => "at-t.app.somleng.org",
        "X-Forwarded-Host" => "example.com"
      }
    )

    expect(response).to have_http_status(:ok)
  end

  it "Allows login to a custom domain" do
    carrier = create(:carrier, subdomain: "at-t")
    user = create(:user, :carrier, carrier:, password: "Super Secret")

    post(
      user_session_path,
      params: {
        user: {
          email: user.email,
          password: "Super Secret",
          otp_attempt: user.current_otp
        }
      },
      headers: {
        "Host" => "at-t.app.somleng.org",
        "X-Forwarded-Host" => "example.com"
      }
    )

    expect(response).to redirect_to("http://example.com/")
  end
end
