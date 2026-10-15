require "rails_helper"

RSpec.describe "Admin/Accounts" do
  it "List accounts" do
    account = create(
      :account,
      :carrier_managed,
      name: "Rocket Rides",
      billing_currency: "USD"
    )
    subscription = create(:tariff_plan_subscription, account:)

    stub_rating_engine_request(result: build(:rating_engine_account_response, balance: 10000))
    page.driver.browser.authorize("admin", "password")
    visit admin_accounts_path

    click_on("Rocket Rides")

    expect(page).to have_text("Rocket Rides")
    expect(page).to have_text("carrier_managed")
    expect(page).to have_text("Current call sessions")
    expect(page).to have_text("Enqueued calls")
    expect(page).to have_text("$100.00")

    click_on(subscription.id)

    expect(page).to have_text(subscription.id)
  end
end
