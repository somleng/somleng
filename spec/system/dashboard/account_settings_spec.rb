require "rails_helper"

RSpec.describe "Account Settings" do
  it "View account settings" do
    account = create(:account, :billing_enabled, name: "Rocket Rides", billing_currency: "USD")
    user = create(
      :user, :with_account_membership, account_role: :owner, account:
    )

    stub_rating_engine_request(result: build(:rating_engine_account_response, balance: 10000))
    carrier_sign_in(user)
    visit dashboard_account_settings_path

    expect(page).to have_text("Rocket Rides")
    expect(page).to have_text("SID")
    expect(page).to have_link("Manage", href: dashboard_auth_tokens_path(filter: { active: true }))

    within("#billing") do
      expect(page).to have_text("$100.00")
    end
  end

  it "Visit account settings as a carrier user" do
    user = create(:user, :carrier)

    carrier_sign_in(user)
    visit dashboard_account_settings_path

    expect(page).to have_text("You are not authorized to perform this action")
    expect(page).to have_current_path(dashboard_carrier_settings_path)
  end

  it "Update account settings" do
    account = create(:account, name: "Rocket Rides")
    user = create(
      :user, :with_account_membership, account_role: :owner, account:
    )

    carrier_sign_in(user)
    visit dashboard_account_settings_path
    click_on("Edit")

    fill_in("Name", with: "Car Rides")
    enhanced_select("Basic.Slt", from: "Default TTS voice")
    click_on("Update Account Settings")

    expect(page).to have_text("Account settings were successfully updated")
    expect(page).to have_text("Car Rides")
    expect(page).to have_text("Basic.Slt (Female, en-US)")
  end
end
