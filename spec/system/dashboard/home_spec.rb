require "rails_helper"

RSpec.describe "Dashboard Home" do
  it "Tells the user they are not a member of any accounts" do
    user = create(:user)

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_content("You are not a member of any accounts.")
  end

  it "Tells the user to select an account", :js do
    user = create(:user)
    account1 = create(:account, name: "Rocket Rides")
    account2 = create(:account, name: "Bob's Bananas")
    create(:account_membership, user: user, account: account1)
    create(:account_membership, user: user, account: account2)

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_content("Please select an account.")

    click_button("Select Account")
    click_link("Rocket Rides")

    expect(page).to have_content("Rocket Rides")
  end

  it "Redirects a carrier user to the carrier home page" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, carrier: carrier)

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_current_path(dashboard_carrier_settings_path)
  end

  it "Redirects an account member to the account home page" do
    account = create(:account)
    user = create(
      :user, :with_account_membership, account_role: :member, account: account
    )

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_current_path(dashboard_account_settings_path)
  end
end
