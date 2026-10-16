require "rails_helper"

RSpec.describe "Authorization" do
  it "rejects requests from unauthorized source IPs" do
    carrier = create(:carrier, :with_oauth_application)
    create(
      :carrier_api_allowed_ip_address,
      ip_address: "13.250.230.15",
      oauth_application: carrier.oauth_application
    )

    get(
      api_carrier_v1_accounts_path,
      headers: build_headers_for(
        carrier,
        "REMOTE_ADDR" => "13.250.230.10"
      )
    )

    expect(response.code).to eq("401")
  end

  it "allows requests from authorized source IPs" do
    carrier = create(:carrier, :with_oauth_application)
    create(
      :carrier_api_allowed_ip_address,
      ip_address: "13.250.230.15",
      oauth_application: carrier.oauth_application
    )

    get(
      api_carrier_v1_accounts_path,
      headers: build_headers_for(
        carrier,
        "REMOTE_ADDR" => "13.250.230.15"
      )
    )

    expect(response.code).to eq("200")
  end

  def build_headers_for(carrier, headers = {})
    api_key = create(:carrier_api_key, oauth_application: carrier.oauth_application)

    {
      "HTTP_AUTHORIZATION" => "Bearer #{api_key.token}",
      "HTTP_HOST" => "api.somleng.org",
      **headers
    }
  end
end
