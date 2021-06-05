require "rails_helper"

RSpec.describe "Account Switcher" do
  it "Carrier user can switch between accounts", :js do
    carrier = create(:carrier, name: "My Carrier")
    user = create(:user, :carrier, carrier: carrier, name: "John Doe")
    create_account_membership(user: user, carrier: carrier, name: "Rocket Rides")
    create_account_membership(user: user, carrier: carrier, name: "Bob's Bananas")

    sign_in(user)
    visit dashboard_accounts_path

    within("#accountSwitcher") do
      click_button("My Carrier")
      expect(page).to have_content("My Accounts")
      expect(page).to have_content("Rocket Rides")
      expect(page).to have_content("Bob's Bananas")
      click_link("Rocket Rides")
    end

    expect(page).to have_current_path(dashboard_root_path)
    within("#sidebar") do
      expect(page).not_to have_content("Accounts")
    end

    within("#accountSwitcher") do
      click_button("Rocket Rides")
      expect(page).to have_content("My Carrier")
      expect(page).to have_content("My Accounts")
      expect(page).to have_content("Bob's Bananas")
      click_link("My Carrier")
    end

    expect(page).to have_current_path(dashboard_root_path)
    within("#sidebar") do
      expect(page).to have_content("Accounts")
    end
  end

  def create_account_membership(user:, **account_attributes)
    account = create(:account, account_attributes)
    create(:account_membership, user: user, account: account)
  end
end
