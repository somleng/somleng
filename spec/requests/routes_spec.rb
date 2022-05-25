require "rails_helper"

RSpec.describe "Routes" do
  it "blocks requests to admin panel for custom domains" do
    expect {
      get(admin_root_path)
    }.to raise_error(ActionController::RoutingError)
  end

  it "blocks requests to sign up for subdomains" do
    expect {
      get(new_user_registration_path)
    }.to raise_error(ActionController::RoutingError)
  end

  it "redirects for requests to somleng.org" do
    carrier = create(:carrier)

    get(docs_url(host: carrier.subdomain_host))

    expect(response).to redirect_to("https://www.somleng.org/carrier_documentation.html")
  end
end
