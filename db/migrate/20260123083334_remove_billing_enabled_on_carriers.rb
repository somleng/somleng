class RemoveBillingEnabledOnCarriers < ActiveRecord::Migration[8.1]
  def change
    remove_column :carriers, :billing_enabled, :boolean, default: false, null: false
  end
end
