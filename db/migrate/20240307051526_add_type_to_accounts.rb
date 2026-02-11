class AddTypeToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column(:accounts, :type, :string, null: false)
    add_index(:accounts, :type)
  end
end
