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

    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("carrier_managed")
    expect(page).to have_content("Current call sessions")
    expect(page).to have_content("Enqueued calls")
    expect(page).to have_content("$100.00")

    click_on(subscription.id)

    expect(page).to have_content(subscription.id)
  end
end
