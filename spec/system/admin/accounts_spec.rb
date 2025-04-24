require "rails_helper"

RSpec.describe "Admin/Accounts" do
  it "List accounts" do
    create(:account, :carrier_managed, name: "Rocket Rides")

    page.driver.browser.authorize("admin", "password")
    visit admin_accounts_path

    click_on("Rocket Rides")

    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("carrier_managed")
    expect(page).to have_content("Current call sessions")
  end
end
