require "rails_helper"

RSpec.describe "Dashboard Home" do
  it "Redirects a carrier user to the carrier home page" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, carrier:)

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_current_path(dashboard_carrier_settings_path)
  end

  it "Redirects an account member to the account home page" do
    account = create(:account)
    user = create(
      :user, :with_account_membership, account_role: :member, account:
    )

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_current_path(dashboard_account_settings_path)
  end
end
