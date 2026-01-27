require "rails_helper"

RSpec.describe SyncRatingEngineTransactions do
  it "syncs rating engine transactions" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    message = create(:message, :inbound, account:)
    topup_balance_transaction = create(:balance_transaction, :topup, account:)

    client = instance_double(
      RatingEngineClient, fetch_cdrs: [
        build_cdr(id: 1000, account_id: account.id, origin_id: message.id, category: message.tariff_category, cost: 100),
        build_cdr(id: 1001, account_id: account.id, balance_transaction_id: topup_balance_transaction.id),
        build_cdr(id: 1002, account_id: account.id, success?: false)
      ]
    )

    perform_enqueued_jobs do
      SyncRatingEngineTransactions.call(client:)
    end

    expect(carrier.balance_transactions).to contain_exactly(
      have_attributes(
        external_id: 1000,
        account:,
        carrier:,
        type: "charge",
        amount: InfinitePrecisionMoney.new(-100, account.billing_currency),
        charge_category: "inbound_messages",
        message: have_attributes(
          price: InfinitePrecisionMoney.new(100, account.billing_currency)
        ),
      ),
      have_attributes(
        external_id: 1001,
        account:,
        carrier:,
        type: "topup",
      ),
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

    perform_enqueued_jobs do
      SyncRatingEngineTransactions.call(client:, batch_size: 2)
    end

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
