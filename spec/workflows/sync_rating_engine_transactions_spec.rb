require "rails_helper"

RSpec.describe SyncRatingEngineTransactions do
  it "syncs rating engine transactions" do
    account = create(:account)
    message = create(:message, :inbound, account:)
    internal_message = create(:message, :outbound, :internal, :sending, account:)
    phone_call = create(:phone_call, :outbound, :initiated, account:)
    internal_phone_call = create(:phone_call, :outbound, :internal, :initiated, account:)
    existing_balance_transaction = create(:balance_transaction, :topup, account:)
    cdrs = [
      build_cdr(id: 1000, account_id: account.id, origin_id: message.id, category: message.tariff_schedule_category, cost: 100),
      build_cdr(id: 1001, account_id: account.id, origin_id: phone_call.external_id, category: phone_call.tariff_schedule_category, cost: 200),
      build_cdr(id: 1002, account_id: account.id, category: phone_call.tariff_schedule_category, cost: 300),
      build_cdr(id: 1003, account_id: account.id, balance_transaction_id: existing_balance_transaction.id),
      build_cdr(id: 1004, account_id: account.id, success?: false),
      build_cdr(id: 1005, account_id: account.id, origin_id: internal_message.id, category: internal_message.tariff_schedule_category),
      build_cdr(id: 1006, account_id: account.id, origin_id: internal_phone_call.external_id, category: internal_phone_call.tariff_schedule_category)
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
        charge_source_id: message.id,
        message: have_attributes(
          price: InfinitePrecisionMoney.new(-100, account.billing_currency)
        )
      ),
      have_attributes(
        external_id: 1001,
        carrier: account.carrier,
        type: "charge",
        amount: InfinitePrecisionMoney.new(-200, account.billing_currency),
        charge_category: "outbound_calls",
        charge_source_id: phone_call.external_id,
        phone_call: have_attributes(
          price: InfinitePrecisionMoney.new(-200, account.billing_currency)
        )
      ),
      have_attributes(
        external_id: 1002,
        carrier: account.carrier,
        type: "charge",
        amount: InfinitePrecisionMoney.new(-300, account.billing_currency),
        charge_category: "outbound_calls",
        charge_source_id: cdrs[2].origin_id,
        phone_call: be_blank
      ),
      have_attributes(
        id: existing_balance_transaction.id,
        external_id: 1003
      ),
      have_attributes(
        external_id: 1005,
        message: have_attributes(
          id: internal_message.id,
        )
      ),
      have_attributes(
        external_id: 1006,
        phone_call: have_attributes(
          id: internal_phone_call.id
        )
      )
    )
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      ReconcileBalanceTransactionChargeSource.to_s,
      account.balance_transactions.find_by(external_id: 1002)
    )
  end

  it "syncs rating engine transactions with pagination" do
    account = create(:account)
    client = instance_double(RatingEngineClient)
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
