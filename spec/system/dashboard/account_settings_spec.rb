require "rails_helper"

RSpec.describe "Account Settings" do
  it "View account settings", :js do
    account = create(:account, :with_access_token, name: "Rocket Rides")
    user = create(
      :user, :with_account_membership, account_role: :member, account:
    )

    carrier_sign_in(user)
    visit dashboard_account_settings_path

    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("SID")
    expect(page).to have_content("Auth Token")
    expect(page).not_to have_content(account.auth_token)

    click_button("Reveal")

    expect(page).to have_content(account.auth_token)
  end

  it "Update account settings" do
    account = create(:account, :with_access_token, name: "Rocket Rides")
    user = create(
      :user, :with_account_membership, account_role: :owner, account:
    )

    carrier_sign_in(user)
    visit dashboard_account_settings_path
    click_link("Edit")

    fill_in("Name", with: "Car Rides")

    within("#default-tts-configuration") do
      choices_select("Basic.Slt", from: "Voice")
    end
    click_button("Update Account Settings")

    expect(page).to have_content("Account settings were successfully updated")
    expect(page).to have_content("Car Rides")
    expect(page).to have_content("Basic.Slt (Female, en-US)")
  end
end
