class AddStatusToAccounts < ActiveRecord::Migration[5.1]
  def up
    add_column(:accounts, :status, :string)
    Account.update_all(:status => "enabled")
    change_column(:accounts, :status, :string, :null => false)
  end

  def down
    remove_column(:accounts, :status)
  end
end
