class RenameAccountStatusToState < ActiveRecord::Migration[5.2]
  def change
    rename_column(:accounts, :status, :state)
  end
end
