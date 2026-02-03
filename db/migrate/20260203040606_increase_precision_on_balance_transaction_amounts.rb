class IncreasePrecisionOnBalanceTransactionAmounts < ActiveRecord::Migration[8.1]
  def change
    change_column(:balance_transactions, :amount_cents, :decimal, precision: 14, scale: 4)
  end
end
