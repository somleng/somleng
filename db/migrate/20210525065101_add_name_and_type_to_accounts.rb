class AddNameAndTypeToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :name, :string

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          account_name = account.settings.fetch("name") { "#{account.carrier.name} Account" }
          account.settings.delete("name")
          account.update_columns(name: account_name, settings: account.settings)
        end
      end
    end

    change_column_null(:accounts, :name, false)
  end
end
