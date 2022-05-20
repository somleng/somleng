class AddConditionalUniqueIndexOnUserEmail < ActiveRecord::Migration[7.0]
  def change
    add_index(:users, :email, unique: true, where: "carrier_role IS NOT NULL")
  end
end
