class AddBillingCurrencyToCarriers < ActiveRecord::Migration[7.1]
  def change
    add_column(:carriers, :billing_currency, :string, null: false)
    add_index(:carriers, :billing_currency)
  end
end
