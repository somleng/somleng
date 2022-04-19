require "rails_helper"

RSpec.describe "Admin/Accounts" do
  it "List accounts" do
    create(:account, name: "Rocket Rides")

    page.driver.browser.authorize("admin", "password")
    visit admin_accounts_path

    click_link("Rocket Rides")

    expect(page).to have_content("Rocket Rides")
  end
end
