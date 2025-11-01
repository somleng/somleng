require "rails_helper"

RSpec.describe "Carrier Settings" do
  it "Update carrier settings" do
    carrier = create(:carrier, name: "My Carrier")
    user = create(:user, :carrier, :owner, carrier:)
    create(:tariff_bundle, carrier:, name: "Standard Bundle")

    carrier_sign_in(user)
    visit dashboard_carrier_settings_path

    click_on("Edit")
    fill_in("Name", with: "T-Mobile")
    select("Zambia", from: "Country")
    choices_select("Zambian Kwacha", from: "Billing currency")
    fill_in("Website", with: "https://t-mobile.example.com")
    fill_in("Webhook URL", with: "https://example.com/webhook_endpoint")
    fill_in("Dashboard host", with: "dashboard.t-mobile.example.com")
    fill_in("API host", with: "api.t-mobile.example.com")
    attach_file("Logo", file_fixture("carrier_logo.jpeg"))
    attach_file("Favicon", file_fixture("favicon-32x32.png"))
    choices_select("Standard Bundle", from: "Default tariff bundle")

    click_on("Update Carrier Settings")

    expect(page).to have_content("Carrier settings were successfully updated")
    expect(page).to have_content("T-Mobile")
    expect(page).to have_content("Zambia")
    expect(page).to have_content("Zambian Kwacha")
    expect(page).to have_content("https://example.com/webhook_endpoint")
    expect(page).to have_content("Webhook signing secret")
    expect(page).to have_content("dashboard.t-mobile.example.com")
    expect(page).to have_content("api.t-mobile.example.com")
    expect(page).to have_xpath("//img[@title='Logo']")
    expect(page).to have_xpath("//img[@title='Favicon']")
    expect(page).to have_content("Standard Bundle")
  end

  it "Update carrier subdomain" do
    carrier = create(:carrier, subdomain: "t-mobile")
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit edit_dashboard_carrier_settings_path
    fill_in("Subdomain", with: "t-mobile2")
    click_on("Update Carrier Settings")

    expect(page.current_host).to eq("http://t-mobile2.app.lvh.me")
    expect(page).to have_current_path(new_user_session_path)

    create(:carrier, subdomain: "t-mobile")
    visit dashboard_root_url(subdomain: "t-mobile.app")
    expect(page).to have_current_path(new_user_session_path)
  end

  it "Disable webhooks" do
    carrier = create(:carrier)
    create(
      :webhook_endpoint,
      oauth_application: carrier.oauth_application,
      url: "https://www.example.com/webhooks"
    )
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit dashboard_carrier_settings_path

    expect(page).to have_content("https://www.example.com/webhooks")

    click_on("Edit")
    uncheck("Enable webhooks")
    click_on("Update Carrier Settings")

    expect(page).to have_content("Carrier settings were successfully updated")
    expect(page).not_to have_content("https://www.example.com/webhooks")
  end
end
