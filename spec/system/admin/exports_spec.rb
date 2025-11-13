require "rails_helper"

RSpec.describe "Admin/Exports" do
  it "List exports" do
    user = create(:user, name: "John Doe")
    create(:export, user:, status_message: "1 of 1,000")

    page.driver.browser.authorize("admin", "password")
    visit admin_exports_path

    expect(page).to have_content("1 of 1,000")
    expect(page).to have_link("John Doe")

    click_on("John Doe")
    expect(page).to have_content(user.id)
  end
end
