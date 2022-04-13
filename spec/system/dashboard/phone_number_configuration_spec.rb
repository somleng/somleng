require "rails_helper"

RSpec.describe "Phone number configuration" do
  it "Configure a phone number as an account admin" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :admin, account:)
    phone_number = create(:phone_number, account:, carrier:)

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
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :admin, account:)
    phone_number = create(:phone_number, account:, carrier:)

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)
    click_link("Edit")

    fill_in("SIP domain", with: "example.sip.twilio.com")
    click_button("Update Configuration")

    expect(page).to have_content("Phone number configuration was successfully updated")
    expect(page).to have_field("SIP domain", with: "example.sip.twilio.com")
  end

  it "Configure a phone number as carrier admin" do
    carrier = create(:carrier)
    account = create(:account, carrier:, name: "Bob's Bananas")
    user = create(:user, :carrier, carrier:)
    phone_number = create(:phone_number, carrier:, account:)

    sign_in(user)
    visit dashboard_phone_number_path(phone_number)
    click_link("Configure")

    fill_in("Voice URL", with: "https://demo.twilio.com/docs/voice.xml")
    select("GET", from: "Voice method")
    click_button("Update Configuration")

    expect(page).to have_content("Phone number configuration was successfully updated")
    expect(page).to have_field("Voice URL", with: "https://demo.twilio.com/docs/voice.xml")
  end

  it "Handles validations" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :admin, account:)
    phone_number = create(:phone_number, account:, carrier:)

    sign_in(user)
    visit edit_dashboard_phone_number_configuration_path(phone_number)

    fill_in("Voice URL", with: "ftp://invalid-url.com")
    click_button("Update Configuration")

    expect(page).to have_content("Voice URL is invalid")
  end
end
