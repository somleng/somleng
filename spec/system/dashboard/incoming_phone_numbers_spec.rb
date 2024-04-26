require "rails_helper"

RSpec.describe "Incoming Phone Numbers" do
  it "List and filter incoming numbers", :js do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    customer_managed_account = create(:account, :customer_managed, carrier:)
    incoming_phone_number = create(
      :incoming_phone_number,
      number: "12513095500",
      voice_url: "https://www.example.com/voice.xml",
      voice_method: "POST",
      sms_url: "https://www.example.com/sms.xml",
      sms_method: "GET",
      account:
    )
    create(:incoming_phone_number, account:, number: "12513095501")
    create(:incoming_phone_number, account: customer_managed_account)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_incoming_phone_numbers_path

    expect(page).to have_link("+1 (251) 309-5500", href: dashboard_incoming_phone_number_path(incoming_phone_number))
    expect(page).to have_content("Webhook to POST: https://www.example.com/voice.xml")
    expect(page).to have_content("Webhook to GET: https://www.example.com/sms.xml")
    expect(page).to have_link("+1 (251) 309-5501")

    click_on("Filter")
    check("Number")
    fill_in("filter[number]", with: "+1 (251) 309-5500")
    click_on("Done")

    expect(page).to have_link("+1 (251) 309-5500", href: dashboard_incoming_phone_number_path(incoming_phone_number))
    expect(page).not_to have_content("+1 (251) 309-5501")
  end

  it "List phone numbers as an account member" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    other_account = create(:account, :customer_managed, carrier: account.carrier)
    create(:incoming_phone_number, account:, carrier:, number: "12513095500")
    create(:incoming_phone_number, account: other_account, number: "12513095501")
    user = create(:user, :with_account_membership, account:, carrier:)

    carrier_sign_in(user)
    visit dashboard_incoming_phone_numbers_path

    expect(page).to have_content("1 (251) 309-5500")
    expect(page).not_to have_content("1 (251) 309-5501")
  end

  it "Show an incoming phone number" do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    messaging_service = create(:messaging_service, carrier:, name: "My Messaging Service")
    incoming_phone_number = create(
      :incoming_phone_number,
      type: :local,
      number: "12513095500",
      voice_url: "https://www.example.com/voice.xml",
      voice_method: "POST",
      sms_url: "https://www.example.com/sms.xml",
      sms_method: "GET",
      messaging_service:,
      account:
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)

    visit dashboard_incoming_phone_number_path(incoming_phone_number)

    within("#properties") do
      expect(page).to have_content("+1 (251) 309-5500")
      expect(page).to have_content("Local")
    end

    within("#voice-configuration") do
      expect(page).to have_content("https://www.example.com/voice.xml")
      expect(page).to have_content("POST")
    end

    within("#messaging-configuration") do
      expect(page).to have_content("https://www.example.com/sms.xml")
      expect(page).to have_content("GET")
      expect(page).to have_link("My Messaging Service", href: dashboard_messaging_service_path(messaging_service))
    end
  end

  it "Configure an incoming phone number" do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    incoming_phone_number = create(:incoming_phone_number, number: "12513095500", account:)
    messaging_service = create(:messaging_service, name: "My Messaging Service", account:, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_incoming_phone_number_path(incoming_phone_number)
    click_on("Edit")

    fill_in("Voice URL", with: "https://www.example.com/voice.xml")
    select("GET", from: "Voice method")
    fill_in("Status callback URL", with: "https://www.example.com/status_callback.xml")
    select("POST", from: "Status callback method")
    fill_in("SMS URL", with: "https://www.example.com/sms.xml")
    select("POST", from: "SMS method")
    choices_select("My Messaging Service", from: "Messaging service")

    click_on("Update (251) 309-5500")

    expect(page).to have_content("Phone number configuration was successfully updated.")

    within("#voice-configuration") do
      expect(page).to have_content("https://www.example.com/voice.xml")
      expect(page).to have_content("GET")
      expect(page).to have_content("https://www.example.com/status_callback.xml")
      expect(page).to have_content("POST")
    end

    within("#messaging-configuration") do
      expect(page).to have_content("https://www.example.com/sms.xml")
      expect(page).to have_content("POST")
      expect(page).to have_link("My Messaging Service", href: dashboard_messaging_service_path(messaging_service))
    end
  end

  it "Handles validations" do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    incoming_phone_number = create(:incoming_phone_number, account:, number: "12513095500")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit edit_dashboard_incoming_phone_number_path(incoming_phone_number)

    fill_in("Voice URL", with: "ftp://invalid-url.com")
    click_on("Update (251) 309-5500")

    expect(page).to have_content("Voice URL is invalid")
  end

  it "Release an incoming phone number" do
    carrier = create(:carrier)
    account = create(:account, :carrier_managed, carrier:)
    incoming_phone_number = create(:incoming_phone_number, number: "12513095500", account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_incoming_phone_number_path(incoming_phone_number)
    click_on("Delete")

    expect(page).to have_content("Phone number was successfully released.")
    expect(page).not_to have_content("+1 (251) 309-5500")
  end
end
