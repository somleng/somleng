class AddOwnerToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :oauth_applications, :owner_type, :string, null: false
    add_index :oauth_applications, [:owner_id, :owner_type]
    add_column :oauth_applications, :confidential, :boolean, null: false, default: true
    change_column_null :oauth_access_tokens, :resource_owner_id, true
    remove_foreign_key :oauth_access_grants, :accounts
    remove_foreign_key :oauth_access_tokens, :accounts
    remove_foreign_key :oauth_applications, :accounts
    add_foreign_key    :oauth_applications, :carriers, column: :owner_id
  end
end
