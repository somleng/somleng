require "rails_helper"

RSpec.describe "Account Settings" do
  it "Account owner can manage their account settings", :js do
    account = create(:account, :with_access_token, name: "Rocket Rides")
    user = create(
      :user, :with_account_membership, account_role: :owner, account: account, name: "Joe Bloggs"
    )

    sign_in(user)
    visit user_root_path
    click_button("Rocket Rides")
    click_link("Account Settings")

    expect(page).to have_content("SID")
    expect(page).to have_content("Auth Token")
    expect(page).not_to have_content(account.auth_token)

    click_button("Reveal")

    expect(page).to have_content(account.auth_token)
  end
end
