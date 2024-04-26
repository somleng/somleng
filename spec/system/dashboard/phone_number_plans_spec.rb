require "rails_helper"

RSpec.describe "Phone Number Plans" do
  it "List, filter and export phone number plans" do
    carrier = create(:carrier, billing_currency: "USD")
    account = create(:account, carrier:, name: "Rocket Rides")
    _active_plan = create(
      :phone_number_plan,
      :active,
      number: "1294",
      type: :short_code,
      amount: Money.from_amount(5.00, "USD"),
      account:
    )
    _canceled_plan = create(:phone_number_plan, :canceled, number: "1279", type: :short_code, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)

    visit dashboard_phone_number_plans_path(
      filter: {
        status: :active
      }
    )

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

  it "Show a phone number plan" do
    carrier = create(:carrier)
    account = create(:account, carrier:, name: "Rocket Rides")
    plan = create(:phone_number_plan, :active, number: "1294", type: :short_code, account:)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_plan_path(plan)

    expect(page).to have_link("1294", href: dashboard_phone_number_path(plan.phone_number))
    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
  end

  it "Buy a phone number as a carrier admin" do
    carrier = create(:carrier)
    create(:account, :carrier_managed, carrier:, name: "Rocket Rides")
    create(:account, :customer_managed, carrier:, name: "Customer Account")
    phone_number = create(:phone_number, number: "12513095500", carrier:)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit(new_dashboard_phone_number_plan_path(phone_number_id: phone_number))

    expect(page).not_to have_choices_select("Account", with_options: [ "Customer Account" ])
    choices_select("Rocket Rides", from: "Account")
    click_on("Buy +1 (251) 309-5500")

    expect(page).to have_content("Phone number plan was successfully created.")
    expect(page).to have_content("Active")
  end

  it "Buy a phone number as an account admin" do
    carrier = create(:carrier)
    account = create(:account, :customer_managed, carrier:)
    phone_number = create(:phone_number, number: "12513095500", carrier:)
    user = create(:user, :with_account_membership, account:, carrier:)

    carrier_sign_in(user)
    visit(new_dashboard_phone_number_plan_path(phone_number_id: phone_number))

    click_on("Buy +1 (251) 309-5500")

    expect(page).to have_content("Phone number plan was successfully created.")
    expect(page).to have_content("Active")
  end

  it "Handles validations" do
    carrier = create(:carrier)
    phone_number = create(:phone_number, number: "12513095500", carrier:)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit(new_dashboard_phone_number_plan_path(phone_number_id: phone_number))

    click_on("Buy +1 (251) 309-5500")

    expect(page).to have_content("can't be blank")
  end
end
