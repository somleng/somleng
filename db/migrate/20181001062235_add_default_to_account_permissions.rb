class AddDefaultToAccountPermissions < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:accounts, :permissions, 0)
  end
end
