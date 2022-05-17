require "rails_helper"

RSpec.describe "Custom Domains" do
  it "Setup custom domain" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, :owner, carrier:)

    sign_in(user)
    visit dashboard_carrier_settings_path
    within("#custom-domain-configuration") do
      click_link("Configure")
    end

    fill_in("Dashboard host", with: "xyz-dashboard.example.com")
    fill_in("API host", with: "xyz-api.example.com")
    fill_in("Mail host", with: "example.com")

    perform_enqueued_jobs(except: ScheduledJob) do
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

    within("#mail-domain-settings") do
      expect(page).to have_content("example.com")
      expect(page).to have_content("Pending Verification")
    end
  end

  it "Manually verify a custom domain" do
    carrier = create(:carrier, :with_oauth_application)
    create(:custom_domain, carrier:, host: "example.com")
    user = create(:user, :carrier, :owner, carrier:)

    sign_in(user)
    visit edit_dashboard_carrier_settings_custom_domain_path
    click_link("Verify")

    expect(page).to have_content("Not all domains were verified successfully. Please check your DNS settings and try again later")
  end

  it "Remove a custom domain" do
    carrier = create(:carrier, :with_oauth_application, :with_custom_domain)
    user = create(:user, :carrier, :owner, carrier:)

    sign_in(user)
    visit edit_dashboard_carrier_settings_custom_domain_path

    perform_enqueued_jobs do
      click_link("Delete")
    end

    expect(page).to have_content("Custom domain was successfully destroyed")
  end

  it "Regenerates an expired mail custom domain" do
    carrier = create(:carrier, :with_oauth_application)
    create(:custom_domain, :mail, :expired, carrier:)
    user = create(:user, :carrier, :owner, carrier:)

    sign_in(user)
    visit edit_dashboard_carrier_settings_custom_domain_path

    click_link("Restart")

    expect(page).to have_content("Custom domain was successfully regenerated")
  end

  it "Account owner can login to a custom domain" do
    carrier = create(:carrier, :with_logo, name: "Test Carrier")
    user = create(:user, :with_account_membership, carrier:)
    create(:custom_domain, :verified, :api, carrier:, host: "api.example.com")
    create(:custom_domain, :verified, :dashboard, carrier:, host: "dashboard.example.com")

    page.driver.header("X-Forwarded-Host", "dashboard.example.com")

    sign_in(user)
    visit dashboard_phone_calls_path

    expect(page).to have_css("img[alt='Test Carrier']")
    expect(page).to have_link("API Documentation", href: "http://api.example.com/docs")
  end
end
