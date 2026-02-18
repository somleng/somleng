require "rails_helper"

RSpec.describe SyncRatingEngineTransactions do
  it "syncs rating engine transactions" do
    account = create(:account)
    message = create(:message, :inbound, account:)
    phone_call = create(:phone_call, :outbound, :initiated, account:)
    existing_balance_transaction = create(:balance_transaction, :topup, account:)
    cdrs = [
      build_cdr(id: 1000, account_id: account.id, origin_id: message.id, category: message.tariff_schedule_category, cost: 100),
      build_cdr(id: 1001, account_id: account.id, phone_call_id: phone_call.id, category: phone_call.tariff_schedule_category, cost: 200),
      build_cdr(id: 1002, account_id: account.id, balance_transaction_id: existing_balance_transaction.id),
      build_cdr(id: 1003, account_id: account.id, success?: false)
    ]
    client = instance_double(RatingEngineClient, fetch_cdrs: cdrs)

    SyncRatingEngineTransactions.call(client:)

    expect(account.balance_transactions).to contain_exactly(
      have_attributes(
        external_id: 1000,
        carrier: account.carrier,
        type: "charge",
        amount: InfinitePrecisionMoney.new(-100, account.billing_currency),
        charge_category: "inbound_messages",
        message: have_attributes(
          id: message.id,
          price: InfinitePrecisionMoney.new(-100, account.billing_currency)
        )
      ),
      have_attributes(
        external_id: 1001,
        carrier: account.carrier,
        type: "charge",
        amount: InfinitePrecisionMoney.new(-200, account.billing_currency),
        charge_category: "outbound_calls",
        phone_call: have_attributes(
          id: phone_call.id,
          price: InfinitePrecisionMoney.new(-200, account.billing_currency)
        )
      ),
      have_attributes(
        id: existing_balance_transaction.id,
        external_id: 1002
      ),
    )
  end

  it "syncs rating engine transactions with pagination" do
    account = create(:account)
    message1 = create(:message, account:)
    message2 = create(:message, account:)
    client = instance_double(RatingEngineClient)
    allow(client).to receive(:fetch_cdrs).with(last_id: nil, limit: 2).and_return(
      [
        build_cdr(id: 1000, account_id: account.id, origin_id: message1.id, category: message1.tariff_schedule_category),
        build_cdr(id: 1001, account_id: account.id, origin_id: message2.id, category: message2.tariff_schedule_category),
      ]
    )
    allow(client).to receive(:fetch_cdrs).with(last_id: 1001, limit: 2).and_return(
      [
        build_cdr(id: 1001, account_id: account.id, origin_id: message2.id, category: message2.tariff_schedule_category),
      ]
    )

    SyncRatingEngineTransactions.call(client:, batch_size: 2)

    expect(client).to have_received(:fetch_cdrs).twice
  end

  def build_cdr(**)
    RatingEngineClient::CDR.new(
      id: 1000,
      origin_id: SecureRandom.uuid,
      phone_call_id: nil,
      category: "outbound_messages",
      account_id: build_stubbed(:account).id,
      cost: 100,
      balance_transaction_id: nil,
      extra_info: {},
      success?: true,
      **
    )
  end
end
