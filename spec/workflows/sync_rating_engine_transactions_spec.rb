require "rails_helper"

RSpec.describe SyncRatingEngineTransactions do
  it "syncs rating engine transactions" do
    carrier = create(:carrier)
    accounts = create_list(:account, 2, carrier:)
    message = create(:message, :inbound, account: accounts[0])
    phone_call = create(:phone_call, :outbound, :initiated, account: accounts[0])
    topup_balance_transaction = create(:balance_transaction, :topup, account: accounts[0])
    synced_balance_transaction = create(
      :balance_transaction,
      :charge,
      account: accounts[1],
      amount_cents: -200,
      currency: accounts[1].billing_currency,
      external_id: 1001
    )

    client = instance_double(
      RatingEngineClient, fetch_cdrs: [
        build_cdr(id: 1000, account_id: accounts[0].id, origin_id: message.id, category: message.tariff_category, cost: 100),
        build_cdr(id: 1001, account_id: accounts[1].id, cost: 200),
        build_cdr(id: 1002, account_id: accounts[0].id, balance_transaction_id: topup_balance_transaction.id),
        build_cdr(id: 1003, account_id: accounts[0].id, cost: 300, origin_id: phone_call.external_id, category: phone_call.tariff_category),
        build_cdr(id: 1004, account_id: accounts[0].id, cost: -1)
      ]
    )

    SyncRatingEngineTransactions.call(client:)

    expect(BalanceTransaction.all).to contain_exactly(
      have_attributes(
        external_id: 1000,
        account: accounts[0],
        carrier:,
        type: "charge",
        amount: InfinitePrecisionMoney.new(-100, accounts[0].billing_currency),
        charge_category: "inbound_messages",
        message: have_attributes(
          price: InfinitePrecisionMoney.new(100, accounts[0].billing_currency)
        ),
      ),
      have_attributes(
        external_id: 1001,
        account: accounts[1],
        amount: synced_balance_transaction.amount,
        type: "charge",
      ),
      have_attributes(
        external_id: 1002,
        account: accounts[0],
        carrier:,
        type: "topup",
      ),
      have_attributes(
        external_id: 1003,
        account: accounts[0],
        amount: InfinitePrecisionMoney.new(-300, accounts[0].billing_currency),
        charge_category: "outbound_calls",
        phone_call: have_attributes(
          price: InfinitePrecisionMoney.new(300, accounts[0].billing_currency)
        )
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
      origin_id: SecureRandom.uuid,
      category: "outbound_calls",
      account_id: build_stubbed(:account).id,
      cost: 100,
      balance_transaction_id: nil,
      extra_info: {},
      success?: true,
      **
    )
  end
end
