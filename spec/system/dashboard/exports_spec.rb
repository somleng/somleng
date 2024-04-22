require "rails_helper"

RSpec.describe "Exports" do
  it "Export CSV as a carrier member" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(:account, name: "Rocket Rides", created_at: Time.utc(2021, 12, 1), carrier:)
    create(:account, name: "Alice Apples", created_at: Time.utc(2021, 10, 1), carrier:)
    create(:account, name: "Bob Bananas")

    carrier_sign_in(user)
    visit dashboard_accounts_path(filter: { from_date: "01/12/2021", to_date: "15/12/2021" })
    perform_enqueued_jobs do
      click_on("Export")
    end

    expect(page).to have_current_path(dashboard_accounts_path, ignore_query: true)

    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_on("Exports")
    end

    click_on("accounts_")

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page).to have_content("Rocket Rides")
    expect(page).not_to have_content("Alice Apples")
    expect(page).not_to have_content("Bob Bananas")
  end

  it "Export CSV as an account member" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_account = create(:account, carrier: account.carrier)
    create(:phone_number, account:, carrier:, number: "1234")
    create(:phone_number, account: other_account, carrier:, number: "9876")
    user = create(:user, :with_account_membership, account:)

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path
    perform_enqueued_jobs do
      click_on("Export")
    end
    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_on("Exports")
    end

    click_on("phone_numbers_")
    expect(page).to have_content("1234")
    expect(page).not_to have_content("9876")
  end
end
