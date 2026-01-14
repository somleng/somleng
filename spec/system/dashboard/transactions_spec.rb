require "rails_helper"

RSpec.describe "Transactions" do
  it "List and filter transactions" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    account = create(:account, carrier:)
    topup_transaction = create(:balance_transaction, carrier:, account:, type: :topup)

    excluded_transactions = [
      create(:balance_transaction, carrier:, account:, type: :adjustment),
      create(:balance_transaction, carrier:, type: :topup)
    ]

    carrier_sign_in(user)
    visit dashboard_balance_transactions_path(filter: { type: "topup", account_id: account.id })

    expect(page).to have_content(topup_transaction.id)
    excluded_transactions.each do |transaction|
      expect(page).to have_no_content(transaction.id)
    end
  end

  it "List transactions as an account owner" do
    carrier = create(:carrier)
    user = create(:user, carrier:)
    account = create(:account, carrier:)
    create(:account_membership, user:, account:)
    transaction = create(:balance_transaction, carrier:, account:)

    carrier_sign_in(user)
    visit dashboard_balance_transactions_path

    expect(page).to have_content(transaction.id)
  end

  it "Create a topup transaction" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:, name: "John Doe")
    account = create(:account, carrier:)

    stub_rating_engine_request
    carrier_sign_in(user)
    visit dashboard_balance_transactions_path
    click_on("New")
    enhanced_select(account.name, from: "Account")
    fill_in("Amount", with: "100")
    enhanced_select("Topup", from: "Type")
    fill_in("Description", with: "My description")
    click_on("Create Balance transaction")

    expect(page).to have_content("Balance transaction was successfully created")
    expect(page).to have_link(account.name)
    expect(page).to have_content("$100.00")
    expect(page).to have_content("Topup")
    expect(page).to have_content("My description")
    expect(page).to have_link("John Doe")
  end
end
