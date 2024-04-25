require "rails_helper"

RSpec.describe "Incoming Phone Numbers" do
  it "List and filter incoming numbers" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_account = create(:account, carrier:)
    incoming_phone_number = create(
      :incoming_phone_number,
      number: "12513095500",
      voice_url: "https://www.example.com/voice.xml",
      voice_method: "POST",
      sms_url: "https://www.example.com/sms.xml",
      sms_method: "GET",
      account:
    )
    create(:incoming_phone_number, account: other_account, number: "12513095501")
    user = create(:user, :with_account_membership, account:)

    carrier_sign_in(user)
    visit dashboard_incoming_phone_numbers_path(
      number: "12513095500"
    )

    expect(page).to have_link("+1 (251) 309-5500", href: dashboard_incoming_phone_number_path(incoming_phone_number))
    expect(page).to have_content("Webhook to POST: https://www.example.com/voice.xml")
    expect(page).to have_content("Webhook to GET: https://www.example.com/sms.xml")
  end

  it "Show an incoming phone number", :js, :selenium_chrome do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    incoming_phone_number = create(
      :incoming_phone_number,
      type: :local,
      number: "12513095500",
      voice_url: "https://www.example.com/voice.xml",
      voice_method: "POST",
      sms_url: "https://www.example.com/sms.xml",
      sms_method: "GET",
      account:,
    )
    user = create(:user, :with_account_membership, account:)

    carrier_sign_in(user)

    visit dashboard_incoming_phone_number_path(incoming_phone_number)

    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).to have_content("Local")
    expect(page).to have_content("https://www.example.com/voice.xml")
    expect(page).to have_content("https://www.example.com/sms.xml")
  end

  it "Configure a phone number as an account admin" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :admin, account:)
    phone_number = create(:phone_number, account:, carrier:)
    messaging_service = create(:messaging_service, name: "My Messaging Service", account:, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)
    click_link("Edit")

    fill_in("Voice URL", with: "https://www.example.com/voice.xml")
    select("POST", from: "Voice method")
    fill_in("Status callback URL", with: "https://www.example.com/status_callback.xml")
    select("POST", from: "Status callback method")
    fill_in("SMS URL", with: "https://www.example.com/sms.xml")
    select("POST", from: "SMS method")
    select("My Messaging Service", from: "Messaging service")

    click_button("Update Configuration")

    expect(page).to have_content("Phone number configuration was successfully updated")
    expect(page).to have_field("Voice URL", with: "https://www.example.com/voice.xml")
    expect(page).to have_field("Voice method", with: "POST")
    expect(page).to have_field("Status callback URL", with: "https://www.example.com/status_callback.xml")
    expect(page).to have_field("Status callback method", with: "POST")
    expect(page).to have_field("SMS URL", with: "https://www.example.com/sms.xml")
    expect(page).to have_field("SMS method", with: "POST")
    expect(page).to have_field("Messaging service", with: messaging_service.id)
  end
end
