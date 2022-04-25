class AddRestrictedToCarriers < ActiveRecord::Migration[7.0]
  def change
    add_column :carriers, :restricted, :boolean, null: false, default: false
  end
end
