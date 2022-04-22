require "rails_helper"

RSpec.describe "Phone Numbers" do
  it "List and filter phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(
      :phone_number,
      carrier:,
      number: "855972222222",
      created_at: Time.utc(2021, 12, 1)
    )
    create(
      :phone_number,
      carrier:,
      number: "855973333333",
      created_at: Time.utc(2021, 10, 10)
    )
    create(
      :phone_number,
      :disabled,
      carrier:,
      number: "855974444444",
      created_at: Time.utc(2021, 12, 1)
    )

    sign_in(user)
    visit dashboard_phone_numbers_path(
      filter: { from_date: "01/12/2021", to_date: "15/12/2021", enabled: true }
    )

    expect(page).to have_content("855972222222")
    expect(page).not_to have_content("855973333333")
    expect(page).not_to have_content("855974444444")
  end

  it "List phone numbers as an account member" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_account = create(:account, carrier: account.carrier)
    create(:phone_number, account:, carrier:, number: "1234")
    create(:phone_number, account: other_account, carrier:, number: "9876")
    user = create(:user, :with_account_membership, account:)

    sign_in(user)
    visit dashboard_phone_numbers_path

    expect(page).to have_content("1234")
    expect(page).not_to have_content("9876")
  end

  it "Create a phone number", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    create(:account, carrier:, name: "Rocket Rides")

    sign_in(user)
    visit dashboard_phone_numbers_path

    click_link("New")
    fill_in("Number", with: "1234")
    select("Rocket Rides", from: "Account")
    click_button("Create Phone number")

    expect(page).to have_content("Phone number was successfully created")
    expect(page).to have_content("1234")
    expect(page).to have_content("Rocket Rides")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    sign_in(user)
    visit new_dashboard_phone_number_path
    click_button("Create Phone number")

    expect(page).to have_content("can't be blank")
  end

  it "Update a phone number", :js do
    carrier = create(:carrier)
    create(:account, carrier:, name: "Rocket Rides")
    user = create(:user, :carrier, carrier:)
    phone_number = create(:phone_number, carrier:)

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_link("Edit")
    select("Rocket Rides", from: "Account")
    click_button "Update Phone number"

    expect(page).to have_content("Phone number was successfully updated")
    expect(page).to have_content("Rocket Rides")
  end

  it "Delete a phone number" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    phone_number = create(:phone_number, carrier:, number: "1234")
    create(:phone_call, :inbound, carrier:, phone_number:)

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_link("Delete")
    expect(page).to have_content("Phone number was successfully destroyed")
    expect(page).not_to have_content("1234")
  end

  it "Release a phone number" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    account = create(:account, carrier:, name: "Rocket Rides")
    phone_number = create(:phone_number, carrier:, account:, number: "1234")

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_link("Release")
    expect(page).to have_content("Phone number was successfully released")
    expect(page).not_to have_content("Rocket Rides")
  end
end
