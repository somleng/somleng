require "rails_helper"

RSpec.describe "Admin/Carriers" do
  it "List carriers" do
    carrier = create(:carrier, :with_oauth_application, name: "My Carrier")
    create(
      :carrier_api_allowed_ip_address,
      ip_address: "13.250.230.15",
      oauth_application: carrier.oauth_application
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_carriers_path
    click_on("My Carrier")

    expect(page).to have_text("My Carrier")
    expect(page).to have_text("13.250.230.15")
  end
end
