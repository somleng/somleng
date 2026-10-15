require "rails_helper"

RSpec.describe "Admin/Imports" do
  it "List imports" do
    user = create(:user, name: "John Doe")
    create(:import, :phone_numbers, user:)

    page.driver.browser.authorize("admin", "password")
    visit admin_imports_path

    expect(page).to have_text("PhoneNumber")
    expect(page).to have_link("John Doe")

    click_on("John Doe")
    expect(page).to have_text(user.id)
  end
end
