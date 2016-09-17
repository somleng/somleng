class AddPermissionsBitmaskToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column(:accounts, :permissions, :integer, :default => Account::DEFAULT_PERMISSIONS_BITMASK, :null => false)
    change_column(:accounts, :permissions, :integer, :default => nil)
  end
end
