class UsersScopeUniquenessOfEmailToCarrierID < ActiveRecord::Migration[7.0]
  def change
    remove_index(:users, :email)
    add_index(:users, %i[email carrier_id], unique: true)

    reversible do |dir|
      dir.up do
        User.where(carrier_id: nil).joins(:accounts).find_each do |user|
          account = user.accounts.first!
          user.update_columns(carrier_id: account.carrier_id)
        end
      end
    end

    change_column_null(:users, :carrier_id, false)
  end
end
