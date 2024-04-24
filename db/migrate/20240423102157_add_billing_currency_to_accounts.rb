class AddBillingCurrencyToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column(:accounts, :billing_currency, :string)

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE accounts
          SET billing_currency = carriers.billing_currency
          FROM carriers where carriers.id = accounts.carrier_id
        SQL
      end
    end

    change_column_null(:accounts, :billing_currency, false)
    add_index(:accounts, :billing_currency)
  end
end
