require "rails_helper"

RSpec.describe "Users" do
  it "List and filter users" do
    carrier = create(:carrier)
    user = create(:user, carrier: carrier)
    create(:user, name: "John Doe", carrier: carrier, created_at: Time.utc(2021, 12, 1))
    create(:user, name: "Joe Bloggs", carrier: carrier, created_at: Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_users_path(filter: { from_date: "01/12/2021", to_date: "15/12/2021" })

    expect(page).to have_content("John Doe")
    expect(page).not_to have_content("Joe Bloggs")
  end

  it "Create an account" do
    user = create(:user)

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
  end

  it "Handle validation errors" do
    user = create(:user, :admin)

    sign_in(user)
    visit new_dashboard_account_path
    click_button "Create Account"

    expect(page).to have_content("can't be blank")
  end

  it "Update an account" do
    user = create(:user)
    account = create(
      :account,
      :enabled,
      carrier: user.carrier
    )

    sign_in(user)
    visit edit_dashboard_account_path(account)

    fill_in "Name", with: "Rocket Rides 2"
    uncheck("Enabled")
    click_button "Update Account"

    expect(page).to have_content("Account was successfully updated")
    expect(page).to have_content("Rocket Rides 2")
    expect(page).to have_content("Disabled")
  end

  it "Delete an account" do
    user = create(:user)
    account = create(
      :account,
      name: "Rocket Rides",
      carrier: user.carrier
    )

    sign_in(user)
    visit edit_dashboard_account_path(account)

    click_link "Delete"

    expect(page).not_to have_content("Rocket Rides")
  end
end
