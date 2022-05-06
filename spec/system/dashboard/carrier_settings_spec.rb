require "rails_helper"

RSpec.describe "Carrier Settings" do
  it "Update carrier settings" do
    carrier = create(:carrier, :with_oauth_application, name: "My Carrier")
    user = create(:user, :carrier, :owner, carrier: carrier)

    sign_in(user)
    visit dashboard_carrier_settings_path

    click_link("Edit")
    fill_in("Name", with: "T-Mobile")
    select("Zambia", from: "Country")
    fill_in("Webhook URL", with: "https://example.com/webhook_endpoint")
    attach_file("Logo", file_fixture("carrier_logo.jpeg"))
    click_button("Update Carrier Settings")

    expect(page).to have_content("Carrier Settings were successfully updated")
    expect(page).to have_content("T-Mobile")
    expect(page).to have_content("Zambia")
    expect(page).to have_content("https://example.com/webhook_endpoint")
    expect(page).to have_content("Webhook signing secret")
  end

  it "Disable webhooks" do
    carrier = create(:carrier, :with_oauth_application)
    create(:webhook_endpoint, oauth_application: carrier.oauth_application)
    user = create(:user, :carrier, :owner, carrier: carrier)

    sign_in(user)
    visit dashboard_carrier_settings_path

    expect(page).to have_content("Webhook URL")

    click_link("Edit")
    uncheck("Enable webhooks")
    click_button("Update Carrier Settings")

    expect(page).to have_content("Carrier Settings were successfully updated")
    expect(page).not_to have_content("Webhook URL")
  end
end
