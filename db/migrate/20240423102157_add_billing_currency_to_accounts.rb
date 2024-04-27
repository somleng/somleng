class AddBillingCurrencyToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column(:accounts, :billing_currency, :string, null: false)
    add_index(:accounts, :billing_currency)
  end
end
