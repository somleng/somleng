require "rails_helper"

RSpec.describe "Accounts" do
  it "List and filter accounts", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    create(:account, name: "Rocket Rides", carrier: carrier, created_at: Time.utc(2021, 12, 1))
    create(:account, name: "Garry Gas", carrier: carrier, created_at: Time.utc(2021, 12, 10))
    create(:account, name: "Alice Apples", carrier: carrier, created_at: Time.utc(2021, 10, 1))
    create(:account, :disabled, name: "Disabled Account", carrier: carrier, created_at: Time.utc(2021, 12, 10))

    sign_in(user)
    visit dashboard_accounts_path(filter: { from_date: "01/12/2021", to_date: "15/12/2021" })
    click_button("Filter")
    check("Status")
    select("Enabled", from: "filter[status]")
    click_button("Done")

    expect(page).to have_content("Filter 2")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("Garry Gas")
    expect(page).not_to have_content("Alice Apples")
    expect(page).not_to have_content("Disabled Account")
    expect(page).not_to have_content("Carrier Account")
  end

  it "Create an account" do
    user = create(:user, :carrier)

    sign_in(user)
    visit dashboard_accounts_path
    click_link("New")

    fill_in "Name", with: "Rocket Rides"
    click_button "Create Account"

    expect(page).to have_content("Account was successfully created")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("Enabled")
    expect(page).to have_link("Edit")
    expect(page).to have_content("Auth Token")
    expect(page).to have_content("Carrier managed")
  end

  it "Handle validation errors" do
    user = create(:user, :carrier)

    sign_in(user)
    visit new_dashboard_account_path
    click_button "Create Account"

    expect(page).to have_content("can't be blank")
  end

  it "Update an account", :js do
    user = create(:user, :carrier)
    account = create(
      :account,
      :enabled,
      carrier: user.carrier
    )
    outbound_sip_trunk = create(:outbound_sip_trunk, carrier: user.carrier, name: "Main SIP Trunk")

    sign_in(user)
    visit dashboard_account_path(account)
    click_link("Edit")
    uncheck("Enabled")
    select("Main SIP Trunk", from: "Outbound SIP trunk")
    click_button "Update Account"

    expect(page).to have_content("Account was successfully updated")
    expect(page).to have_link(
      "Main SIP Trunk", href: dashboard_outbound_sip_trunk_path(outbound_sip_trunk)
    )
    expect(page).to have_content("Disabled")
  end

  it "Delete an account" do
    user = create(:user, :carrier)
    account = create(
      :account,
      name: "Rocket Rides",
      carrier: user.carrier
    )

    sign_in(user)
    visit dashboard_account_path(account)

    click_link "Delete"

    expect(page).not_to have_content("Rocket Rides")
  end
end
