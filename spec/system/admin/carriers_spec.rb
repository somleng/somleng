require "rails_helper"

RSpec.describe "Admin/Carriers" do
  it "List carriers" do
    create(:carrier, name: "My Carrier")

    page.driver.browser.authorize("admin", "password")
    visit admin_carriers_path
    click_link("My Carrier")

    expect(page).to have_content("My Carrier")
  end
end
