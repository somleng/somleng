require "rails_helper"

RSpec.describe "Admin/Verifications" do
  it "List verifications" do
    account = create(:account, name: "Rocket Rides")
    verification_service = create(:verification_service, name: "Rides Service", account:)
    verification = create(:verification, verification_service:)

    page.driver.browser.authorize("admin", "password")
    visit admin_verifications_path

    click_on(verification.id)
    click_on("Rides Service")

    expect(page).to have_link("Rocket Rides", href: admin_account_path(account))
  end
end
