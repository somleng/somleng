require "rails_helper"

RSpec.describe SyncRatingEngineTransactions do
  it "syncs rating engine transactions" do
    carrier = create(:carrier)
    account1 = create(:account, carrier:)
    account2 = create(:account, carrier:)
    topup_balance_transaction = create(:balance_transaction, :topup, account: account1)
    synced_balance_transaction = create(
      :balance_transaction,
      :charge,
      account: account2,
      amount: Money.from_amount(-200, account2.billing_currency),
      external_id: 1001
    )

    client = instance_double(RatingEngineClient, fetch_cdrs: [
      build_cdr(id: 1000, account_id: account1.id, cost: 100),
      build_cdr(id: 1001, account_id: account2.id, cost: 200),
      build_cdr(id: 1002, account_id: account1.id, balance_transaction_id: topup_balance_transaction.id),
      build_cdr(id: 1003, account_id: account1.id, cost: -1)
    ])

    SyncRatingEngineTransactions.call(client:)

    expect(BalanceTransaction.all).to contain_exactly(
      have_attributes(
        account: account1,
        carrier: carrier,
        type: "charge",
        amount: Money.from_amount(-100, account1.billing_currency),
        external_id: 1000
      ),
      have_attributes(
        account: account2,
        amount: synced_balance_transaction.amount,
        external_id: 1001,
        type: "charge",
      ),
      have_attributes(
        account: account1,
        carrier: carrier,
        external_id: 1002,
        type: "topup",
      )
    )
  end

  it "syncs rating engine transactions with pagination" do
    client = instance_double(RatingEngineClient)
    account = create(:account)
    allow(client).to receive(:fetch_cdrs).with(last_id: nil, limit: 2).and_return(
      [
        build_cdr(id: 1000, account_id: account.id),
        build_cdr(id: 1001, account_id: account.id)
      ]
    )

    allow(client).to receive(:fetch_cdrs).with(last_id: 1001, limit: 2).and_return(
      [
        build_cdr(id: 1001, account_id: account.id)
      ]
    )

    SyncRatingEngineTransactions.call(client:, batch_size: 2)

    expect(BalanceTransaction.count).to eq(2)
    expect(client).to have_received(:fetch_cdrs).twice
  end

  def build_cdr(**)
    RatingEngineClient::CDR.new(
      id: 1000,
      account_id: build_stubbed(:account).id,
      cost: 100,
      balance_transaction_id: nil,
      **
    )
  end
end
