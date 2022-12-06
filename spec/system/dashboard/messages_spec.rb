require "rails_helper"

RSpec.describe "Messages" do
  it "List and filter messages" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    message = create(
      :message,
      :sending,
      direction: :outbound_api,
      account:,
      to: "85512234232",
      from: "1294",
      created_at: Time.utc(2021, 12, 1),
      price: "-0.001",
      price_unit: "MXN"
    )
    filtered_message = create(
      :message,
      account:,
      status: :sent,
      created_at: message.created_at,
      to: message.to,
      from: message.from
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_messages_path(
      filter: {
        from_date: "01/12/2021",
        to_date: "15/12/2021",
        to: "+855 12 234 232 ",
        from: "1294",
        status: :sending
      }
    )

    expect(page).to have_content(message.id)
    expect(page).to have_content("+85512234232")
    expect(page).to have_content("1294")
    expect(page).not_to have_content(filtered_message.id)

    perform_enqueued_jobs do
      click_on("Export")
    end

    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_link("Exports")
    end

    click_link("messages_")

    expect(page).to have_content(message.id)
    expect(page).to have_content("outbound-api")
    expect(page).to have_content("-0.001")
    expect(page).to have_content("MXN")
    expect(page).not_to have_content(filtered_message.id)
  end

  it "Shows a message" do
    carrier = create(:carrier)
    account = create(:account, name: "Rocket Rides", carrier:)
    phone_number = create(:phone_number, carrier:, number: "855715100980")
    sms_gateway = create(:sms_gateway, name: "My SMS Gateway", carrier:)
    message = create(
      :message,
      body: "Hello World",
      direction: :outbound_api,
      from: "855715100980",
      to: "855715999999",
      sms_gateway:,
      account:,
      phone_number:,
      price: "-0.001",
      price_unit: "MXN",
      encoding: "GSM"
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_message_path(message)

    expect(page).to have_content(message.id)
    expect(page).to have_content("Hello World")
    expect(page).to have_content("+855715100980")
    expect(page).to have_content("+855715999999")
    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
    expect(page).to have_content("Outbound-API")
    expect(page).to have_link(
      "SMS Gateway",
      href: dashboard_sms_gateway_path(sms_gateway)
    )
    expect(page).to have_link("855715100980", href: dashboard_phone_number_path(phone_number))
    expect(page).to have_content("-$0.001000")
    expect(page).to have_content("MXN")
    expect(page).to have_content("GSM")
  end
end
