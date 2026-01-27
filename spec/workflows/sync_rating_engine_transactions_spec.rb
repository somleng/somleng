require "rails_helper"

RSpec.describe SyncRatingEngineTransactions do
  it "syncs rating engine transactions" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    message = create(:message, :inbound, account:)
    existing_balance_transaction = create(:balance_transaction, :topup, account:)
    cdrs = [
      build_cdr(id: 1000, account_id: account.id, origin_id: message.id, category: message.tariff_category, cost: 100),
      build_cdr(id: 1001, account_id: account.id, balance_transaction_id: existing_balance_transaction.id),
      build_cdr(id: 1002, account_id: account.id, success?: false)
    ]

    client = instance_double(RatingEngineClient, fetch_cdrs: cdrs)

    SyncRatingEngineTransactions.call(client:)

    expect(ProcessRatingEngineCDRJob).to have_been_enqueued.once
    expect(ProcessRatingEngineCDRJob).to have_been_enqueued.with(cdrs[0].to_h).once
    expect(existing_balance_transaction.reload).to have_attributes(
      external_id: 1001
    )
  end

  it "syncs rating engine transactions with pagination" do
    client = instance_double(RatingEngineClient)
    allow(client).to receive(:fetch_cdrs).with(last_id: nil, limit: 2).and_return(
      [ build_cdr(id: 1000), build_cdr(id: 1001) ]
    )
    allow(client).to receive(:fetch_cdrs).with(last_id: 1001, limit: 2).and_return(
      [ build_cdr(id: 1001) ]
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
