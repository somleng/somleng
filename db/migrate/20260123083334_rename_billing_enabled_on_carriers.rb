class RenameBillingEnabledOnCarriers < ActiveRecord::Migration[8.1]
  def change
    rename_column :carriers, :billing_enabled, :default_billing_enabled
  end
end
