class AddNameAndTypeToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :name, :string, null: false
  end
end
