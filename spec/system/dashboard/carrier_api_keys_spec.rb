require "rails_helper"

RSpec.describe "Carrier API Keys" do
  it "List API keys" do
    carrier = create(:carrier, :with_oauth_application)
    api_key = create(:carrier_api_key, oauth_application: carrier.oauth_application)
    revoked_api_key = create(:carrier_api_key, :revoked, oauth_application: carrier.oauth_application)
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit dashboard_carrier_settings_path
    click_on("Manage API keys")

    expect(page).to have_text(api_key.id)
    expect(page).to have_no_text(revoked_api_key.id)
  end

  it "Show an API key" do
    carrier = create(:carrier, :with_oauth_application)
    api_key = create(:carrier_api_key, oauth_application: carrier.oauth_application)
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit dashboard_carrier_settings_api_key_path(api_key)

    expect(page).to have_text(api_key.id)
    expect(page).to have_text("Active")
  end

  it "Create an API key" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit dashboard_carrier_settings_api_keys_path
    click_on("Create")

    expect(page).to have_text("API key was successfully created.")
  end

  it "Revoke an API key" do
    carrier = create(:carrier, :with_oauth_application)
    api_key = create(:carrier_api_key, oauth_application: carrier.oauth_application)
    user = create(:user, :carrier, :owner, carrier:)

    carrier_sign_in(user)
    visit dashboard_carrier_settings_api_key_path(api_key)
    click_on("Revoke")

    expect(page).to have_text("API key was successfully revoked.")
    expect(page).to have_text("Revoked")
  end
end
