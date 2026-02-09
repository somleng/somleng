require "rails_helper"

RSpec.describe "Balance Transactions" do
  it "List and filter balance transactions" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    account = create(:account, carrier:)
    balance_transaction = create(
      :balance_transaction,
      :for_phone_call,
      carrier:,
      account:,
      phone_call: create(:phone_call, :completed, :outbound, account:, carrier:)
    )

    excluded_transactions = [
      create(:balance_transaction, carrier:, account:, type: :topup),
      create(:balance_transaction, carrier:, account:, type: :adjustment),
      create(:balance_transaction, carrier:, type: :charge, charge_category: :outbound_calls)
    ]

    carrier_sign_in(user)
    visit dashboard_balance_transactions_path(
      filter: {
        type: "charge",
        charge_category: "outbound_calls",
        account_id: account.id
      }
    )

    expect(page).to have_content(balance_transaction.id)
    excluded_transactions.each do |transaction|
      expect(page).to have_no_content(transaction.id)
    end
  end

  it "List balance transactions as an account owner" do
    carrier = create(:carrier)
    user = create(:user, carrier:)
    account = create(:account, carrier:)
    create(:account_membership, user:, account:)
    balance_transaction = create(
      :balance_transaction,
      carrier:, account:,
      created_by: create(:user, :carrier, carrier:, name: "John Doe")
    )

    carrier_sign_in(user)
    visit dashboard_balance_transactions_path
    click_on(balance_transaction.id)

    expect(page).to have_content(balance_transaction.id)
    expect(page).to have_no_link(account.id)
    expect(page).to have_no_link("John Doe")
  end

  it "Create a topup balance transaction" do
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

  it "show a balance transaction" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)
    account = create(:account, carrier:)
    balance_transaction = create(:balance_transaction, :for_phone_call, account:)

    carrier_sign_in(user)
    visit dashboard_balance_transaction_path(balance_transaction)

    expect(page).to have_content("Outbound calls")
    expect(page).to have_link("Phone call", href: dashboard_phone_call_path(balance_transaction.phone_call))
  end
end
