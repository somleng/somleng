require "rails_helper"

RSpec.describe "Phone Numbers" do
  it "List and filter phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    create(:phone_number, carrier: carrier, number: "855972222222", created_at: Time.utc(2021, 12, 1))
    create(:phone_number, carrier: carrier, number: "855973333333", created_at: Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_phone_numbers_path(
      filter: { from_date: "01/12/2021", to_date: "15/12/2021" }
    )

    expect(page).to have_content("855972222222")
    expect(page).not_to have_content("855973333333")
  end

  it "List phone numbers as an account member" do
    carrier = create(:carrier)
    account = create(:account, carrier: carrier)
    other_account = create(:account, carrier: account.carrier)
    create(:phone_number, account: account, carrier: carrier, number: "1234")
    create(:phone_number, account: other_account, carrier: carrier, number: "9876")
    user = create(:user, :with_account_membership, account: account)

    sign_in(user)
    visit dashboard_phone_numbers_path

    expect(page).to have_content("1234")
    expect(page).not_to have_content("9876")
  end

  it "Create a phone number", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier: carrier)
    create(:account, carrier: carrier, name: "Rocket Rides")

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
    account = create(:account, carrier: carrier, name: "Bob's Bananas")
    create(:account, carrier: carrier, name: "Rocket Rides")
    user = create(:user, :carrier, carrier: carrier)
    phone_number = create(:phone_number, carrier: carrier, account: account)

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_link("Edit")
    fill_in("Number", with: "1234")
    select("Rocket Rides", from: "Account")
    click_button "Update Phone number"

    expect(page).to have_content("Phone number was successfully updated")
    expect(page).to have_content("1234")
    expect(page).to have_content("Rocket Rides")
  end

  it "Delete a phone number" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    phone_number = create(:phone_number, carrier: carrier, number: "1234")

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_link("Delete")
    expect(page).to have_content("Phone number was successfully destroyed")
    expect(page).not_to have_content("1234")
  end

  it "Configure a phone number as an account admin" do
    carrier = create(:carrier)
    account = create(:account, carrier: carrier)
    user = create(:user, :with_account_membership, account_role: :admin, account: account)
    phone_number = create(:phone_number, account: account, carrier: carrier)

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)
    click_link("Edit")

    fill_in("Voice URL", with: "https://www.example.com/voice.xml")
    select("POST", from: "Voice method")
    fill_in("Status callback URL", with: "https://www.example.com/status_callback.xml")
    select("POST", from: "Status callback method")
    click_button("Update Configuration")

    expect(page).to have_content("Phone number configuration was successfully updated")
    expect(page).to have_field("Voice URL", with: "https://www.example.com/voice.xml")
    expect(page).to have_field("Voice method", with: "POST")
    expect(page).to have_field("Status callback URL", with: "https://www.example.com/status_callback.xml")
    expect(page).to have_field("Status callback method", with: "POST")
  end

  it "Configure a phone number with sip domain as an account admin" do
    carrier = create(:carrier)
    account = create(:account, carrier: carrier)
    user = create(:user, :with_account_membership, account_role: :admin, account: account)
    phone_number = create(:phone_number, account: account, carrier: carrier)

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)
    click_link("Edit")

    fill_in("SIP domain", with: "example.sip.twilio.com")
    click_button("Update Configuration")

    expect(page).to have_content("Phone number configuration was successfully updated")
    expect(page).to have_field("SIP domain", with: "example.sip.twilio.com")
  end

  it "Handles validations" do
    carrier = create(:carrier)
    account = create(:account, carrier: carrier)
    user = create(:user, :with_account_membership, account_role: :admin, account: account)
    phone_number = create(:phone_number, account: account, carrier: carrier)

    sign_in(user)
    visit edit_dashboard_phone_number_configuration_path(phone_number)

    fill_in("Voice URL", with: "ftp://invalid-url.com")
    click_button("Update Configuration")

    expect(page).to have_content("Voice URL is invalid")
  end
end
