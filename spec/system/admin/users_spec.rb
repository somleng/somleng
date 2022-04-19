require "rails_helper"

RSpec.describe "Admin/Users" do
  it "List users" do
    account = create(:account, name: "Rocket Rides")
    user = create(:user, name: "John Doe")
    account_membership = create(:account_membership, user:, account:, role: :admin)

    page.driver.browser.authorize("admin", "password")
    visit admin_users_path
    click_link("John Doe")

    expect(page).to have_content("John Doe")
    click_link(account_membership.id)

    expect(page).to have_link("John Doe")
    expect(page).to have_link("Rocket Rides")
    expect(page).to have_content("admin")
  end
end
