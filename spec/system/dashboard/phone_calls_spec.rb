require "rails_helper"

RSpec.describe "Phone Calls" do
  it "List and filter phone calls" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    incoming_phone_number = create(:incoming_phone_number, account:)
    phone_call = create(
      :phone_call,
      :outbound,
      account:,
      incoming_phone_number:,
      to: "85512234232",
      from: "1294",
      created_at: Time.utc(2021, 12, 1),
      price: InfinitePrecisionMoney.from_amount(-0.001, "MXN")
    )
    filtered_out_phone_calls = [
      create(:phone_call, account:, created_at: Time.utc(2021, 10, 10)),
      create(:phone_call, account:, created_at: phone_call.created_at),
      create(
        :phone_call,
        account:,
        created_at: phone_call.created_at,
        to: phone_call.to,
        from: phone_call.from
      )
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_calls_path(
      filter: {
        from_date: "01/12/2021",
        to_date: "15/12/2021",
        to: "+855 12 234 232 ",
        from: "1294",
        id: phone_call.id,
        phone_number_id: incoming_phone_number.id
      }
    )

    expect(page).to have_content(phone_call.id)
    expect(page).to have_content("+855 12 234 232")
    expect(page).to have_content("1294")
    filtered_out_phone_calls.each do |filtered_out_phone_call|
      expect(page).to have_no_content(filtered_out_phone_call.id)
    end

    perform_enqueued_jobs do
      click_on("Export")
    end

    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_on("Exports")
    end

    click_on("phone_calls_")
    expect(page).to have_content(phone_call.id)
    expect(page).to have_content("outbound-api")
    expect(page).to have_content("-0.001")
    expect(page).to have_content("MXN")

    filtered_out_phone_calls.each do |filtered_out_phone_call|
      expect(page).to have_no_content(filtered_out_phone_call.id)
    end
  end

  it "Show a phone call" do
    carrier = create(:carrier, billing_currency: "MXN")
    account = create(:account, name: "Rocket Rides", carrier:)
    incoming_phone_number = create(:incoming_phone_number, account:, number: "12513095500")
    sip_trunk = create(:sip_trunk, name: "SIP Trunk", carrier:)
    phone_call = create(
      :phone_call,
      :inbound,
      from: "855715100980",
      to: "12513095500",
      voice_url: "https://demo.twilio.com/docs/voice.xml",
      sip_trunk:,
      account:,
      incoming_phone_number:,
      price: InfinitePrecisionMoney.from_amount(-0.001, "MXN")
    )
    balance_transaction = create(
      :balance_transaction, :for_phone_call, phone_call:, amount: phone_call.price, account:
    )
    create(:recording, :completed, phone_call:)
    create(:call_data_record, bill_sec: 5, phone_call:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_call_path(phone_call)

    expect(page).to have_content(phone_call.id)
    expect(page).to have_content("+855 71 510 0980")
    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
    expect(page).to have_content("5 seconds")
    expect(page).to have_content("Inbound")
    expect(page).to have_content("https://demo.twilio.com/docs/voice.xml")
    expect(page).to have_link(
      "SIP Trunk",
      href: dashboard_sip_trunk_path(sip_trunk)
    )
    expect(page).to have_link(
      balance_transaction.id,
      href: dashboard_balance_transaction_path(balance_transaction)
    )
    expect(page).to have_link(incoming_phone_number.id, href: dashboard_incoming_phone_number_path(incoming_phone_number))
    expect(page).to have_content("-$0.00100")
    expect(page).to have_content("MXN")
    expect(page).to have_content("Recordings")
    expect(page).to have_link(
      "View",
      href: dashboard_events_path(filter: { phone_call_id: phone_call.id })
    )
    expect(page).to have_link(
      "View",
      href: dashboard_tts_events_path(filter: { phone_call_id: phone_call.id })
    )
  end
end
