require "rails_helper"

RSpec.describe "Messaging Services" do
  it "List and filter messaging services" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    create(:messaging_service, account:, carrier:, name: "My Messaging Service")
    create(:messaging_service, account:, carrier:, name: "Foobar")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit(dashboard_messaging_services_path(filter: { name: "Messaging" }))

    expect(page).to have_content("My Messaging Service")
    expect(page).not_to have_content("Foobar")
  end

  it "Shows a messaging service" do
    messaging_service = create(:messaging_service, name: "My Messaging Service")
    incoming_phone_number = create(
      :incoming_phone_number,
      messaging_service:,
      number: "855715999999",
      account: messaging_service.account
    )
    user = create(:user, :carrier, carrier: messaging_service.carrier)

    carrier_sign_in(user)
    visit dashboard_messaging_service_path(messaging_service)

    expect(page).to have_link(
      "+855 71 599 9999",
      href: dashboard_incoming_phone_number_path(incoming_phone_number)
    )
    expect(page).to have_content("My Messaging Service")
  end

  it "Create a messaging service", :js do
    carrier = create(:carrier)
    account = create(:account, carrier:, name: "Rocket Rides")
    create(
      :incoming_phone_number,
      account:,
      number: "855715777777"
    )
    create(
      :incoming_phone_number,
      account:,
      number: "855715888888"
    )

    user = create(:user, :carrier, :admin, carrier:)
    carrier_sign_in(user)
    visit dashboard_messaging_services_path

    click_on("New")
    fill_in("Name", with: "My Messaging Service")
    enhanced_select("Rocket Rides", from: "Account")
    click_on("Next")

    enhanced_select("+855 71 577 7777", from: "Phone numbers")
    enhanced_select("+855 71 588 8888", from: "Phone numbers")
    choose("Send a webhook")
    fill_in("Inbound request URL", with: "https://www.example.com/message.xml")
    select("POST", from: "Inbound request method")
    fill_in("Status callback URL", with: "https://www.example.com/status_callback.xml")
    check("Smart encoding")

    click_on("Save")

    expect(page).to have_content("Messaging service was successfully updated")
    expect(page).to have_content("My Messaging Service")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_link("+855 71 577 7777")
    expect(page).to have_link("+855 71 588 8888")
    expect(page).to have_content("https://www.example.com/message.xml")
    expect(page).to have_content("https://www.example.com/status_callback.xml")
    expect(page).to have_content("Webhook")
  end

  it "Create a messaging service as an account admin" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :admin, account:)

    carrier_sign_in(user)
    visit new_dashboard_messaging_service_path

    fill_in("Name", with: "My Messaging Service")
    click_button("Next")
    click_button("Save")

    expect(page).to have_content("Messaging service was successfully updated")
    expect(page).to have_content("My Messaging Service")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_messaging_service_path
    click_on "Next"

    expect(page).to have_content("can't be blank")
  end

  it "Update a messaging service" do
    messaging_service = create(:messaging_service, name: "Default")
    create(
      :incoming_phone_number,
      messaging_service:,
      account: messaging_service.account,
      number: "855715777777"
    )
    create(
      :incoming_phone_number,
      account: messaging_service.account,
      number: "855715888888"
    )
    user = create(:user, :carrier, :admin, carrier: messaging_service.carrier)
    carrier_sign_in(user)

    visit dashboard_messaging_service_path(messaging_service)
    click_on("Edit")
    fill_in("Name", with: "My Messaging Service")
    enhanced_select("+855 71 577 7777", from: "Phone numbers")
    enhanced_select("+855 71 588 8888", from: "Phone numbers")
    fill_in("Inbound request URL", with: "https://www.example.com/message.xml")
    select("POST", from: "Inbound request method")
    fill_in("Status callback URL", with: "https://www.example.com/status_callback.xml")

    check("Smart encoding")

    click_on "Save"

    expect(page).to have_content("Messaging service was successfully updated")
    expect(page).to have_content("My Messaging Service")
    expect(page).to have_link("+855 71 577 7777")
    expect(page).to have_link("+855 71 588 8888")
    expect(page).to have_content("https://www.example.com/message.xml")
    expect(page).to have_content("https://www.example.com/status_callback.xml")
    expect(page).to have_content("Smart encodingYes")
  end

  it "Delete a messaging service" do
    messaging_service = create(:messaging_service, name: "My Channel Group")
    create(
      :incoming_phone_number,
      messaging_service:,
      account: messaging_service.account,
      number: "855715777777"
    )
    user = create(:user, :carrier, :admin, carrier: messaging_service.carrier)

    carrier_sign_in(user)
    visit dashboard_messaging_service_path(messaging_service)

    click_on("Delete")

    expect(page).to have_content("Messaging service was successfully destroyed")
    expect(page).not_to have_content("My Channel Group")
  end
end
