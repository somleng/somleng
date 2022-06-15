class AddCallsPerSecondToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :calls_per_second, :integer, default: 1, null: false
  end
end
