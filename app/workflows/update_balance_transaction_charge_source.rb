class UpdateBalanceTransactionChargeSource < ApplicationWorkflow
  attr_reader :balance_transaction

  def initialize(balance_transaction)
    super()
    @balance_transaction = balance_transaction
  end

  def call
    return if charge_source.blank?
    return if charge_source.price.present?

    charge_source.update_columns(
      price_cents: balance_transaction.amount.cents,
      price_unit: balance_transaction.amount.currency.to_s
    )
  end

  private

  def charge_source
    @charge_source ||= balance_transaction.charge_source
  end
end
