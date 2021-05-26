require "rails_helper"

RSpec.describe "Exports" do
  it "Export accounts" do
    carrier = create(:carrier)
    user = create(:user, carrier: carrier)
    create(:account, name: "Rocket Rides", created_at: Time.utc(2021, 12, 1), carrier: carrier)
    create(:account, name: "Alice Apples", created_at: Time.utc(2021, 10, 1), carrier: carrier)
    create(:account, name: "Bob Bananas")

    sign_in(user)
    visit dashboard_accounts_path(filter: { from_date: "01/12/2021", to_date: "15/12/2021" })
    perform_enqueued_jobs do
      click_link("Export")
    end

    expect(page).to have_current_path(dashboard_accounts_path, ignore_query: true)

    within(".alert") do
      expect(page).to have_content("Your export is being processed")
      click_link("Exports")
    end

    click_link("accounts_")

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page).to have_content("Rocket Rides")
    expect(page).not_to have_content("Alice Apples")
    expect(page).not_to have_content("Bob Bananas")
  end
end
