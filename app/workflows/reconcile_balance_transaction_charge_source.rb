class ReconcileBalanceTransactionChargeSource < ApplicationWorkflow
  attr_reader :balance_transaction

  def initialize(balance_transaction)
    super()
    @balance_transaction = balance_transaction
  end

  def call
    return if balance_transaction.phone_call_id.present?

    ApplicationRecord.transaction do
      balance_transaction.update_columns(phone_call_id: phone_call.id)
      UpdateBalanceTransactionChargeSource.call(balance_transaction)
    end
  end

  private

  def phone_call
    CallDataRecord.find_by!(external_id: balance_transaction.charge_source_id).phone_call
  end
end
