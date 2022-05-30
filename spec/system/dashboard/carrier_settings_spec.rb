require "rails_helper"

RSpec.describe "Carrier Settings" do
  it "Update carrier settings" do
    carrier = create(:carrier, name: "My Carrier")
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit dashboard_carrier_settings_path

    click_link("Edit")
    fill_in("Name", with: "T-Mobile")
    select("Zambia", from: "Country")
    fill_in("Website", with: "https://t-mobile.example.com")
    fill_in("Webhook URL", with: "https://example.com/webhook_endpoint")
    fill_in("Dashboard host", with: "dashboard.t-mobile.example.com")
    fill_in("API host", with: "api.t-mobile.example.com")
    attach_file("Logo", file_fixture("carrier_logo.jpeg"))
    click_button("Update Carrier Settings")

    expect(page).to have_content("Carrier Settings were successfully updated")
    expect(page).to have_content("T-Mobile")
    expect(page).to have_content("Zambia")
    expect(page).to have_content("https://example.com/webhook_endpoint")
    expect(page).to have_content("Webhook signing secret")
    expect(page).to have_content("dashboard.t-mobile.example.com")
    expect(page).to have_content("api.t-mobile.example.com")
  end

  it "Update carrier subdomain" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit edit_dashboard_carrier_settings_path
    fill_in("Subdomain", with: "t-mobile")
    click_button("Update Carrier Settings")

    expect(page.current_host).to eq("http://t-mobile.app.lvh.me")
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

    click_link("Edit")
    uncheck("Enable webhooks")
    click_button("Update Carrier Settings")

    expect(page).to have_content("Carrier Settings were successfully updated")
    expect(page).not_to have_content("https://www.example.com/webhooks")
  end
end
