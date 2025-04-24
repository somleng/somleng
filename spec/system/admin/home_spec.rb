require "rails_helper"

RSpec.describe "Admin/Home" do
  it "Shows a home dashboard" do
    page.driver.browser.authorize("admin", "password")
    visit admin_homes_path

    expect(page).to have_content("Current call sessions")
    expect(page).to have_content("Call sessions limit")
    expect(page).to have_content("Per account call sessions limit")
    expect(page).to have_content("Switch capacity")
  end
end
