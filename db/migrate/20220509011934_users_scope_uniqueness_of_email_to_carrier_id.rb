class UsersScopeUniquenessOfEmailToCarrierID < ActiveRecord::Migration[7.0]
  def change
    remove_index(:users, :email)
    add_index(:users, %i[email carrier_id], unique: true)
    change_column_null(:users, :carrier_id, false)
  end
end
