require "rails_helper"

RSpec.describe "Phone Number Plans" do
  it "List, filter and export phone number plans" do
    carrier = create(:carrier, billing_currency: "USD")
    account = create(:account, carrier:, name: "Rocket Rides")
    _active_plan = create(
      :phone_number_plan,
      :active,
      number: "1294",
      amount: Money.from_amount(5.00, "USD"),
      account:
    )
    _canceled_plan = create(:phone_number_plan, :canceled, number: "1279", account:)
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

  it "Manage phone number plans as an account member" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_account = create(:account, carrier: account.carrier)
    active_plan = create(:phone_number_plan, :active, account:, number: "1294")
    canceled_plan = create(:phone_number_plan, :canceled, account:, number: "1279")
    create(:phone_number_plan, account: other_account, carrier:, number: "8888")
    user = create(:user, :with_account_membership, account:)

    carrier_sign_in(user)
    visit dashboard_phone_number_plans_path

    expect(page).to have_link("1294", href: dashboard_phone_number_plan_path(active_plan))
    expect(page).to have_link("1279",  href: dashboard_phone_number_plan_path(canceled_plan))
    expect(page).not_to have_content("8888")

    click_on("1294")

    expect(page).to have_content("Active")

    click_on("Cancel")

    expect(page).to have_content("Canceled")
  end

  it "Show a phone number plan" do
    carrier = create(:carrier)
    account = create(:account, carrier:, name: "Rocket Rides")
    plan = create(:phone_number_plan, :active, number: "1294", account:)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_plan_path(plan)

    expect(page).to have_link("1294", href: dashboard_phone_number_path(plan.phone_number))
    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
  end

  it "Cancel a phone number plan" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    plan = create(:phone_number_plan, :active, account:)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_plan_path(plan)

    click_on("Cancel")
    expect(page).to have_content("Phone number plan was successfully canceled")
    expect(page).to have_content("Canceled")
  end
end
