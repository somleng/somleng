require "rails_helper"

RSpec.describe "Custom Domains" do
  it "Setup custom domain" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, :owner, carrier:)

    sign_in(user)
    visit edit_dashboard_custom_domain_path

    fill_in("Dashboard host", with: "xyz-dashboard.example.com")
    fill_in("API host", with: "xyz-api.example.com")

    perform_enqueued_jobs do
      click_button("Save Custom Domain")
    end

    expect(page).to have_content("xyz-dashboard.example.com")
    expect(page).to have_content("xyz-api.example.com")
  end
end
