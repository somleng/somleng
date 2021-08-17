class AddOwnerToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :oauth_applications, :owner_type, :string, null: true
    add_index :oauth_applications, [:owner_id, :owner_type]
    add_column :oauth_applications, :confidential, :boolean, null: false, default: true
  end
end
