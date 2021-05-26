class AddNameAndTypeToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :name, :string
    add_column :accounts, :type, :string

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          account_name = account.settings.fetch("name") { "#{account.carrier.name} Account" }
          account.settings.delete("name")
          account.update_columns(name: account_name, settings: account.settings)
        end

        Account.update_all(type: :customer)
      end
    end

    change_column_null(:accounts, :name, false)
    change_column_null(:accounts, :type, false)
  end
end
