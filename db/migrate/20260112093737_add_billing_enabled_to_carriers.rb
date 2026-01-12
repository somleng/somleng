class AddBillingEnabledToCarriers < ActiveRecord::Migration[8.1]
  def change
    add_column :carriers, :billing_enabled, :boolean, default: false, null: false
    add_index :carriers, :billing_enabled
  end
end
