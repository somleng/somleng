class RemovePermissionsFromAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column(:accounts, :permissions)
  end
end
