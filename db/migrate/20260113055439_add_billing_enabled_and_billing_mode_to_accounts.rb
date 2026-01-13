class AddBillingEnabledAndBillingModeToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column(:accounts, :billing_enabled, :boolean, null: false, default: false)
    add_column(:accounts, :billing_mode, :string)
    add_index(:accounts, :billing_enabled)

    reversible do |dir|
      dir.up do
        Account.update_all(billing_mode: :prepaid)
      end
    end

    change_column_null(:accounts, :billing_mode, false)
  end
end
