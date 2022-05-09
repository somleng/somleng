require "rails_helper"

RSpec.describe "Account Switcher" do
  it "User can switch between accounts", :js do
    carrier = create(:carrier)
    user = create(:user, name: "John Doe", carrier:)
    create_account_membership(user:, carrier:, name: "Rocket Rides")
    create_account_membership(user:, carrier:, name: "Bob's Bananas")

    sign_in(user)
    visit dashboard_root_path

    within("#accountSwitcher") do
      click_button("Select Account")
      expect(page).to have_content("My Accounts")
      expect(page).to have_content("Rocket Rides")
      expect(page).to have_content("Bob's Bananas")
      click_link("Rocket Rides")
    end

    expect(page).to have_current_path(dashboard_account_settings_path)
    expect(page).to have_content("Rocket Rides")

    within("#accountSwitcher") do
      click_button("Rocket Rides")
      expect(page).to have_content("My Accounts")
      expect(page).to have_content("Bob's Bananas")
      click_link("Bob's Bananas")
    end

    expect(page).to have_current_path(dashboard_account_settings_path)
    expect(page).to have_content("Bob's Bananas")
  end

  def create_account_membership(user:, **account_attributes)
    account = create(:account, account_attributes)
    create(:account_membership, user:, account:)
  end
end
