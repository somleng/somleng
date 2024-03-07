class AddTypeToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column(:accounts, :type, :string)
    add_index(:accounts, :type)

    reversible do |dir|
      dir.up do
        Account.where(account_memberships_count: 1..).update_all(type: :customer_managed)
        Account.where(account_memberships_count: 0).update_all(type: :carrier_managed)
      end
    end

    change_column_null(:accounts, :type, false)
  end
end
