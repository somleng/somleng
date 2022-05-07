require "rails_helper"

RSpec.describe "Custom Domains" do
  it "Setup custom domain" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, :owner, carrier:)

    sign_in(user)
    visit dashboard_carrier_settings_path
    within("#custom-domain-configuration") do
      click_link("Setup")
    end

    fill_in("Dashboard host", with: "xyz-dashboard.example.com")
    fill_in("API host", with: "xyz-api.example.com")

    perform_enqueued_jobs(only: VerifyCustomDomainJob) do
      click_button("Save Custom Domain")
    end

    within("#dashboard-domain-settings") do
      expect(page).to have_content("xyz-dashboard.example.com")
      expect(page).to have_content("Pending Verification")
    end

    within("#api-domain-settings") do
      expect(page).to have_content("xyz-api.example.com")
      expect(page).to have_content("Pending Verification")
    end
  end

  it "Remove a custom domain" do
    carrier = create(:carrier, :with_oauth_application, :with_custom_domain)
    user = create(:user, :carrier, :owner, carrier:)

    sign_in(user)
    visit dashboard_carrier_settings_path
    within("#custom-domain-configuration") do
      click_link("Manage")
    end

    click_link("Delete")

    expect(page).to have_content("Custom domain was successfully destroyed")
    within("#custom-domain-configuration") do
      expect(page).to have_link("Setup")
    end
  end
end
