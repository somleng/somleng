require "rails_helper"

RSpec.describe ReconcileBalanceTransactionChargeSource do
  it "reconciles the balance transaction charge source" do
    phone_call = create(:phone_call, :outbound, :completed)
    balance_transaction = create(:balance_transaction, :charge, charge_category: :outbound_calls, charge_source_id: phone_call.external_id)

    ReconcileBalanceTransactionChargeSource.call(balance_transaction)

    expect(balance_transaction).to have_attributes(
      phone_call: have_attributes(
        price: balance_transaction.amount
      )
    )
  end

  it "handles existing charge sources" do
    balance_transaction = create(:balance_transaction, :for_phone_call)

    ReconcileBalanceTransactionChargeSource.call(balance_transaction)

    expect(balance_transaction).to have_attributes(
      phone_call: balance_transaction.phone_call
    )
  end

  it "raises when the phone call cannot be found" do
    balance_transaction = create(:balance_transaction, :charge, charge_category: :outbound_calls)

    expect { ReconcileBalanceTransactionChargeSource.call(balance_transaction) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
