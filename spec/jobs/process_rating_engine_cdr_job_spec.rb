require "rails_helper"

RSpec.describe ProcessRatingEngineCDRJob do
  it "handles a message cdr" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    message = create(:message, :inbound, account:)

    cdr =  build_cdr(
      id: 1000,
      account_id: account.id,
      origin_id: message.id,
      category: message.tariff_category,
      cost: 100
    )

    ProcessRatingEngineCDRJob.perform_now(cdr)

    expect(carrier.balance_transactions.count).to eq(1)
    expect(carrier.balance_transactions.last).to have_attributes(
      external_id: 1000,
      account:,
      carrier:,
      type: "charge",
      amount: InfinitePrecisionMoney.new(-100, account.billing_currency),
      charge_category: "inbound_messages",
      message: have_attributes(
        price: InfinitePrecisionMoney.new(100, account.billing_currency)
      ),
    )
  end

  it "handles a phone call cdr" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    phone_call = create(:phone_call, :outbound, :initiated, account:)

    cdr = build_cdr(
      id: 1000,
      account_id: account.id,
      cost: 300,
      origin_id: phone_call.external_id,
      category: phone_call.tariff_category
    )

    ProcessRatingEngineCDRJob.perform_now(cdr)

    expect(carrier.balance_transactions.count).to eq(1)
    expect(carrier.balance_transactions.last).to have_attributes(
      external_id: 1000,
      account:,
      carrier:,
      type: "charge",
      amount: InfinitePrecisionMoney.new(-300, account.billing_currency),
      charge_category: "outbound_calls",
      phone_call: have_attributes(
        price: InfinitePrecisionMoney.new(300, account.billing_currency)
      ),
    )
  end

  it "handles existing balance transactions" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    synced_balance_transaction = create(
      :balance_transaction,
      :charge,
      account:,
      amount_cents: -200,
      currency: account.billing_currency,
      external_id: 1001
    )

    cdr = build_cdr(
      id: synced_balance_transaction.external_id,
      account_id: account.id,
    )

    ProcessRatingEngineCDRJob.perform_now(cdr)

    expect(carrier.balance_transactions.count).to eq(1)
    expect(carrier.balance_transactions.last).to have_attributes(
      external_id: 1001,
      account:,
      carrier:,
      type: "charge",
      amount: InfinitePrecisionMoney.new(-200, account.billing_currency),
    )
  end

  it "retries on missing calls" do
    account = create(:account)

    cdr = build_cdr(
      account_id: account.id,
      origin_id: SecureRandom.uuid,
      category: "outbound_calls"
    )

    ProcessRatingEngineCDRJob.perform_now(cdr)

    expect(ProcessRatingEngineCDRJob).to have_been_enqueued
  end

  def build_cdr(**)
    RatingEngineClient::CDR.new(
      id: 1000,
      account_id: build_stubbed(:account).id,
      origin_id: SecureRandom.uuid,
      category: "inbound_messages",
      cost: 100,
      balance_transaction_id: nil,
      extra_info: {},
      success?: true,
      **
    ).to_h
  end
end
