require "rails_helper"

RSpec.describe "Admin/Messages" do
  it "List messages" do
    sms_gateway = create(:sms_gateway, name: "GoIP")
    create(
      :sms_gateway_channel_group,
      sms_gateway:,
      name: "Smart",
      route_prefixes: [ "85510" ]
    )
    account = create(:account, carrier: sms_gateway.carrier, name: "Rocket Rides")
    messaging_service = create(
      :messaging_service,
      :webhook,
      account:,
      name: "My Messaging Service",
      inbound_request_url: "https://example.com/messages.xml"
    )
    incoming_phone_number = create(
      :incoming_phone_number,
      number: "855718224112",
      messaging_service:,
      account:
    )
    message = create(
      :message,
      to: "855718224112",
      account:,
      sms_gateway:,
      messaging_service:,
      incoming_phone_number:
    )
    internal_message = create(:message, :internal)

    page.driver.browser.authorize("admin", "password")
    visit admin_messages_path

    expect(page).to have_content(internal_message.id)
    click_on("855718224112")

    expect(page).to have_link("Rocket Rides", href: admin_account_path(account))
    expect(page).to have_link("855718224112", href: admin_incoming_phone_number_path(incoming_phone_number))

    click_on("My Messaging Service")

    expect(page).to have_content("https://example.com/messages.xml")

    click_on(message.id)
    click_on("GoIP")
    click_on("Smart")

    expect(page).to have_content("85510")
  end
end
