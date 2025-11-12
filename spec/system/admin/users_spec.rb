require "rails_helper"

RSpec.describe "Admin/Users" do
  it "List users" do
    account = create(:account, name: "Rocket Rides")
    inviting_user = create(:user, name: "Joe Bloggs")
    user = create(:user, name: "John Doe", invited_by: inviting_user)
    create(:account_membership, user: inviting_user, account:)
    import = create(:import, user:)
    export = create(:export, user:)
    account_membership = create(:account_membership, user:, account:, role: :admin)
    create(:error_log_notification, user:, carrier: user.carrier)

    page.driver.browser.authorize("admin", "password")
    visit admin_users_path
    click_on("John Doe")

    expect(page).to have_content("John Doe")
    expect(page).to have_link("Joe Bloggs")
    expect(page).to have_link(import.id)
    expect(page).to have_link(export.id)

    click_on(account_membership.id)

    expect(page).to have_link("John Doe")
    expect(page).to have_link("Rocket Rides")
    expect(page).to have_content("admin")
  end
end
