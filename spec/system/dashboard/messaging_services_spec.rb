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
    phone_number = create(
      :phone_number,
      :configured,
      messaging_service:,
      number: "855715999999",
      account: messaging_service.account,
      carrier: messaging_service.carrier
    )
    user = create(:user, :carrier, carrier: messaging_service.carrier)

    carrier_sign_in(user)
    visit dashboard_messaging_service_path(messaging_service)

    expect(page).to have_link(
      "855715999999",
      href: dashboard_phone_number_path(phone_number)
    )
    expect(page).to have_content("My Messaging Service")
  end

  it "Create a messaging service" do
    carrier = create(:carrier)
    account = create(:account, carrier:, name: "Rocket Rides")
    create(
      :phone_number,
      account:,
      carrier:,
      number: "855715777777"
    )
    create(
      :phone_number,
      account:,
      carrier:,
      number: "855715888888"
    )

    user = create(:user, :carrier, :admin, carrier:)
    carrier_sign_in(user)
    visit dashboard_messaging_services_path

    click_link("New")
    fill_in("Name", with: "My Messaging Service")
    select("Rocket Rides", from: "Account")
    click_button("Next")

    select("855715777777", from: "Phone numbers")
    select("855715888888", from: "Phone numbers")
    fill_in("Inbound request URL", with: "https://www.example.com/message.xml")
    select("POST", from: "Inbound request method")
    fill_in("Status callback URL", with: "https://www.example.com/status_callback.xml")
    check("Smart encoding")
    click_button("Save")

    expect(page).to have_content("Messaging service was successfully updated")
    expect(page).to have_content("My Messaging Service")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_link("855715777777")
    expect(page).to have_link("855715888888")
    expect(page).to have_content("https://www.example.com/message.xml")
    expect(page).to have_content("https://www.example.com/status_callback.xml")
    expect(page).to have_content("Smart encodingYes")
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
    click_button "Next"

    expect(page).to have_content("can't be blank")
  end

  it "Update a messaging service" do
    messaging_service = create(:messaging_service, name: "Default")
    create(
      :phone_number,
      :configured,
      messaging_service:,
      account: messaging_service.account,
      carrier: messaging_service.carrier,
      number: "855715777777"
    )
    create(
      :phone_number,
      :configured,
      account: messaging_service.account,
      carrier: messaging_service.carrier,
      number: "855715888888"
    )
    user = create(:user, :carrier, :admin, carrier: messaging_service.carrier)
    carrier_sign_in(user)

    visit dashboard_messaging_service_path(messaging_service)
    click_link("Edit")
    fill_in("Name", with: "My Messaging Service")
    select("855715777777", from: "Phone numbers")
    select("855715888888", from: "Phone numbers")
    fill_in("Inbound request URL", with: "https://www.example.com/message.xml")
    select("POST", from: "Inbound request method")
    fill_in("Status callback URL", with: "https://www.example.com/status_callback.xml")

    check("Smart encoding")

    click_button "Save"

    expect(page).to have_content("Messaging service was successfully updated")
    expect(page).to have_content("My Messaging Service")
    expect(page).to have_link("855715777777")
    expect(page).to have_link("855715888888")
    expect(page).to have_content("https://www.example.com/message.xml")
    expect(page).to have_content("https://www.example.com/status_callback.xml")
    expect(page).to have_content("Smart encodingYes")
  end

  it "Delete a messaging service" do
    messaging_service = create(:messaging_service, name: "My Channel Group")
    create(
      :phone_number,
      :configured,
      messaging_service:,
      account: messaging_service.account,
      carrier: messaging_service.carrier,
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
