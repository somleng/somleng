require "rails_helper"

RSpec.describe "Account Switcher" do
  it "User can switch between accounts", :js do
    carrier = create(:carrier)
    user = create(:user, name: "John Doe", carrier:)
    create_account_membership(user:, carrier:, name: "Rocket Rides", current_membership: true)
    create_account_membership(user:, carrier:, name: "Bob's Bananas")

    carrier_sign_in(user)
    visit dashboard_account_settings_path

    within("#accountSwitcher") do
      click_button("Rocket Rides")
      click_link("Bob's Bananas")
    end

    within("#accountSettings") do
      expect(page).to have_content("Bob's Bananas")
    end
  end

  def create_account_membership(user:, current_membership: false, **account_attributes)
    account = create(:account, account_attributes)
    account_membership = create(:account_membership, user:, account:)
    user.update!(current_account_membership: account_membership) if current_membership
    account_membership
  end
end
