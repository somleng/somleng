class AddBillingEnabledAndBillingModeToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column(:accounts, :billing_enabled, :boolean, null: false, default: false)
    add_column(:accounts, :billing_mode, :string, null: false)
    add_index(:accounts, :billing_enabled)
  end
end
