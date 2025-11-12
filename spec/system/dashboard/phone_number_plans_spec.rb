require "rails_helper"

RSpec.describe "Phone Number Plans" do
  it "List, filter and export phone number plans" do
    carrier = create(:carrier, billing_currency: "USD")
    account = create(:account, carrier:, name: "Rocket Rides")
    active_plan = create(
      :phone_number_plan,
      :active,
      number: "12513095500",
      amount: Money.from_amount(5.00, "USD"),
      account:
    )
    canceled_plan = create(:phone_number_plan, :canceled, number: "12513095501", account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_plans_path

    expect(page).to have_link("+1 (251) 309-5500", href: dashboard_incoming_phone_number_path(active_plan.incoming_phone_number))
    expect(page).to have_link("+1 (251) 309-5501", href: dashboard_incoming_phone_number_path(canceled_plan.incoming_phone_number))

    visit dashboard_phone_number_plans_path(filter: { status: :active })

    expect(page).to have_link("+1 (251) 309-5500")
    expect(page).to have_content("$5.00")
    expect(page).to have_content("Active")
    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
    expect(page).to have_no_content("+1 (251) 309-5501")

    perform_enqueued_jobs do
      click_on("Export")
    end

    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_on("Exports")
    end

    click_on("phone_number_plans_")

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page).to have_content("12513095500")
    expect(page).to have_content("5.00")
    expect(page).to have_content("USD")
    expect(page).to have_content("active")
    expect(page).to have_content(account.id)
  end

  it "Show a phone number plan" do
    carrier = create(:carrier)
    account = create(:account, carrier:, name: "Rocket Rides")
    plan = create(:phone_number_plan, :active, number: "1294", type: :short_code, account:)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_plan_path(plan)

    expect(page).to have_link("1294", href: dashboard_incoming_phone_number_path(plan.incoming_phone_number))
    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
  end

  it "Buy a phone number" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    phone_number = create(
      :phone_number,
      visibility:
      :public,
      iso_country_code: "CA",
      number: "16473095500",
      iso_region_code: "ON",
      locality: "Toronto",
      carrier:
    )
    user = create(:user, :with_account_membership, account:, carrier:)

    carrier_sign_in(user)
    visit(new_dashboard_phone_number_plan_path(phone_number_id: phone_number))

    expect(page).to have_content("Canada")
    expect(page).to have_content("Toronto")
    expect(page).to have_content("Ontario")

    click_on("Buy +1 (647) 309-5500")

    expect(page).to have_content("Phone number plan was successfully created.")
    expect(page).to have_content("Configure +1 (647) 309-5500")
  end
end
