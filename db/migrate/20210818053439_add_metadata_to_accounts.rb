class AddMetadataToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :metadata, :jsonb, default: {}, null: false
  end
end
