require "rails_helper"

RSpec.describe "Admin/BalanceTransactions" do
  it "List balance transactions" do
    transaction = create(:balance_transaction, type: :topup)

    page.driver.browser.authorize("admin", "password")
    visit admin_balance_transactions_path
    click_on(transaction.id)

    expect(page).to have_content(transaction.id)
    expect(page).to have_content("topup")
  end
end
