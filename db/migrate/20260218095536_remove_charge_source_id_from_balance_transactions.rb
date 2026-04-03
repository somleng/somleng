class RemoveChargeSourceIDFromBalanceTransactions < ActiveRecord::Migration[8.1]
  def change
    remove_column :balance_transactions, :charge_source_id, :string
  end
end
