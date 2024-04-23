require "rails_helper"

RSpec.describe "Phone Numbers" do
  it "List, filter and bulk delete phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(
      :phone_number,
      :utilized,
      :configured,
      carrier:,
      iso_country_code: "KH",
      number: "855972222222",
      type: :mobile,
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
      filter: {
        country: "KH",
        type: "mobile",
        from_date: "01/12/2021",
        to_date: "15/12/2021",
        enabled: true,
        utilized: true,
        configured: true
      }
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

  it "Export phone numbers" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)

    create(
      :phone_number,
      carrier:,
      number: "855972222222",
      iso_country_code: "KH",
      price: Money.from_amount(1.15, "USD")
    )
    create(
      :phone_number,
      carrier:,
      number: "12513095542",
      type: :local,
    )

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path(
      filter: {
        type: "mobile"
      }
    )

    perform_enqueued_jobs do
      click_on("Export")
    end

    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_on("Exports")
    end

    click_on("phone_numbers_")

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page).to have_content("+855972222222")
    expect(page).to have_content("mobile")
    expect(page).to have_content("KH")
    expect(page).to have_content("1.15")
    expect(page).to have_content("USD")

    expect(page).not_to have_content("+12513095542")
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
    fill_in("Number", with: "1294")
    choices_select("Short code", from: "Type")
    click_on("Create Phone number")

    expect(page).to have_content("Phone number was successfully created")
    expect(page).to have_content("1294")
    expect(page).to have_content("Cambodia")
    expect(page).to have_content("Short code")
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_phone_number_path
    click_on("Create Phone number")

    expect(page).to have_content("can't be blank")
  end

  it "Update a phone number" do
    carrier = create(:carrier, billing_currency: "CAD")
    create(:account, carrier:, name: "Rocket Rides")

    user = create(:user, :carrier, carrier:)
    phone_number = create(:phone_number, carrier:, number: "12505550199", iso_country_code: "US")

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_on("Edit")
    choices_select("Rocket Rides", from: "Account")
    choices_select("Canada", from: "Country")
    choices_select("Mobile", from: "Type")
    fill_in("Price", with: "1.15")

    click_on("Update Phone number")

    expect(page).to have_content("Phone number was successfully updated")

    within("#billing") do
      expect(page).to have_content("Rocket Rides")
      expect(page).to have_link("$1.15", href: dashboard_phone_number_plan_path(phone_number.active_plan))
    end

    within("#properties") do
      expect(page).to have_content("Canada")
      expect(page).to have_content("Mobile")
      expect(page).to have_content("$1.15")
    end
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
