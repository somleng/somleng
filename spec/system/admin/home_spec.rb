require "rails_helper"

RSpec.describe "Admin/Home" do
  it "Shows a home dashboard" do
    page.driver.browser.authorize("admin", "password")
    visit admin_homes_path

    expect(page).to have_content("Current call sessions")
  end
end
