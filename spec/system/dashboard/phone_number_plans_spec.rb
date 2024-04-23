require "rails_helper"

RSpec.describe "Phone Number Plans" do
  it "List, filter and export phone number plans" do
    carrier = create(:carrier, billing_currency: "USD")
    account = create(:account, carrier:, name: "Rocket Rides")
    phone_number = create(
      :phone_number,
      number: "1294",
      price: Money.from_amount(5.00, "USD"),
      carrier:
    )
    _active_plan = create(:phone_number_plan, phone_number:, account:)
    _canceled_plan = create(:phone_number_plan, :canceled, number: "1279", account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)

    visit dashboard_phone_number_plans_path(
      filter: {
        status: :active
      }
    )

    within("#phone_numbers_dropdown") do
      expect(page).to have_link("Plans", href: dashboard_phone_number_plans_path)
    end

    within(".page-title") do
      expect(page).to have_content("Phone Number Plans")
    end

    expect(page).to have_content("1294")
    expect(page).to have_content("$5.00")
    expect(page).to have_content("Active")
    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
    expect(page).not_to have_content("1279")

    perform_enqueued_jobs do
      click_on("Export")
    end

    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_on("Exports")
    end

    click_on("phone_number_plans_")

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page).to have_content("1294")
    expect(page).to have_content("5.00")
    expect(page).to have_content("USD")
    expect(page).to have_content("active")
    expect(page).to have_content(account.id)
  end

  it "List phone number plans as an account member" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_account = create(:account, carrier: account.carrier)
    create(:phone_number_plan, account:, carrier:, number: "1234")
    create(:phone_number_plan, account: other_account, carrier:, number: "9876")
    user = create(:user, :with_account_membership, account:)

    carrier_sign_in(user)
    visit dashboard_phone_number_plans_path

    within("#phone_numbers_dropdown") do
      expect(page).to have_link("Purchased", href: dashboard_phone_number_plans_path)
    end

    within(".page-title") do
      expect(page).to have_content("Purchased Numbers")
    end
    expect(page).to have_content("1234")
    expect(page).not_to have_content("9876")
  end

  it "Show a phone number plan" do
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

  it "Create a phone number plan" do
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
end
