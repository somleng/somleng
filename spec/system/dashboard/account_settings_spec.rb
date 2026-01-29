require "rails_helper"

RSpec.describe "Account Settings" do
  it "View account settings", :js do
    account = create(:account, :with_access_token, :billing_enabled, name: "Rocket Rides", billing_currency: "USD")
    user = create(
      :user, :with_account_membership, account_role: :member, account:
    )

    stub_rating_engine_request(result: build(:rating_engine_account_response, balance: 10000))
    carrier_sign_in(user)
    visit dashboard_account_settings_path

    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("SID")
    expect(page).to have_content("Auth Token")
    expect(page).to have_no_content(account.auth_token)

    click_on("Reveal")

    expect(page).to have_content(account.auth_token)
    within("#billing") do
      expect(page).to have_content("$100.00")
    end
  end

  it "Visit account settings as a carrier user" do
    user = create(:user, :carrier)

    carrier_sign_in(user)
    visit dashboard_account_settings_path

    expect(page).to have_content("You are not authorized to perform this action")
    expect(page).to have_current_path(dashboard_carrier_settings_path)
  end

  it "Update account settings" do
    account = create(:account, :with_access_token, name: "Rocket Rides")
    user = create(
      :user, :with_account_membership, account_role: :owner, account:
    )

    carrier_sign_in(user)
    visit dashboard_account_settings_path
    click_on("Edit")

    fill_in("Name", with: "Car Rides")
    enhanced_select("Basic.Slt", from: "Default TTS voice")
    click_on("Update Account Settings")

    expect(page).to have_content("Account settings were successfully updated")
    expect(page).to have_content("Car Rides")
    expect(page).to have_content("Basic.Slt (Female, en-US)")
  end
end
