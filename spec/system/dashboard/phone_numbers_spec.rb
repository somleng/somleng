require "rails_helper"

RSpec.describe "Phone Numbers" do
  it "List and filter phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(
      :phone_number,
      :utilized,
      :configured,
      carrier:,
      iso_country_code: "KH",
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

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path(
      filter: { country: "KH", from_date: "01/12/2021", to_date: "15/12/2021", enabled: true, utilized: true, configured: true }
    )

    expect(page).to have_content("+855 97 222 2222")
    expect(page).not_to have_content("+855 97 333 3333")
    expect(page).not_to have_content("+855 97 444 4444")

    click_on("Delete")

    expect(page).to have_content("Phone numbers were successfully destroyed")
    expect(page).not_to have_content("+855 97 222 2222")
    expect(page).not_to have_content("+855 97 333 3333")
    expect(page).not_to have_content("+855 97 444 4444")
    expect(page).not_to have_selector(:link_or_button, "Delete")
  end

  it "List phone numbers as an account member" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_account = create(:account, carrier: account.carrier)
    create(:phone_number, account:, carrier:, number: "1234")
    create(:phone_number, account: other_account, carrier:, number: "9876")
    user = create(:user, :with_account_membership, account:)

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path

    expect(page).to have_content("1234")
    expect(page).not_to have_content("9876")
  end

  it "Show a phone number" do
    carrier = create(:carrier)
    phone_number = create(:phone_number, carrier:)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    expect(page).to have_link(
      "View phone calls",
      href: dashboard_phone_calls_path(filter: { phone_number_id: phone_number.id })
    )
    expect(page).to have_link(
      "View messages",
      href: dashboard_messages_path(filter: { phone_number_id: phone_number.id })
    )
  end

  it "Create a phone number" do
    carrier = create(:carrier, country_code: "KH")
    user = create(:user, :carrier, :admin, carrier:)
    create(:account, carrier:, name: "Rocket Rides")

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path

    click_on("New")
    fill_in("Number", with: "1234")
    choices_select("Rocket Rides", from: "Account")
    click_on("Create Phone number")

    expect(page).to have_content("Phone number was successfully created")
    expect(page).to have_content("1234")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("Cambodia")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_phone_number_path
    click_on("Create Phone number")

    expect(page).to have_content("can't be blank")
  end

  it "Update a phone number" do
    carrier = create(:carrier)
    create(:account, carrier:, name: "Rocket Rides")

    user = create(:user, :carrier, carrier:)
    phone_number = create(:phone_number, carrier:, number: "12505550199", iso_country_code: "US")

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_on("Edit")
    choices_select("Rocket Rides", from: "Account")
    select("Canada", from: "Country")

    click_on("Update Phone number")

    expect(page).to have_content("Phone number was successfully updated")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("Canada")
  end

  it "Delete a phone number" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    phone_number = create(:phone_number, carrier:, number: "1234")
    create(:phone_call, :inbound, carrier:, phone_number:)

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_on("Delete")
    expect(page).to have_content("Phone number was successfully destroyed")
    expect(page).not_to have_content("1234")
  end

  it "Release a phone number" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    account = create(:account, carrier:, name: "Rocket Rides")
    phone_number = create(:phone_number, carrier:, account:, number: "1234")

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_on("Release")
    expect(page).to have_content("Phone number was successfully released")
    expect(page).not_to have_content("Rocket Rides")
  end
end
