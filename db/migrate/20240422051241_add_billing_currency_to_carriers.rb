class AddBillingCurrencyToCarriers < ActiveRecord::Migration[7.1]
  def change
    add_column(:carriers, :billing_currency, :string)

    reversible do |dir|
      dir.up do
        Carrier.find_each do |carrier|
          carrier.update_columns(billing_currency: carrier.country.currency_code)
        end
      end
    end

    change_column_null(:carriers, :billing_currency, false)
    add_index(:carriers, :billing_currency)
  end
end
